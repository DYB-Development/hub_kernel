require "active_support/core_ext/string/inflections"
require "hub_kernel/hubs"

require "hub_kernel/exposes"

module HubKernel
  module Ports
    def port(name, as:)
      Hubs.add(self)
      declared_ports << name
      singleton_class.attr_writer name
      define_singleton_method(name) { instance_variable_get(:"@#{name}") || unwired(name) }
      define_singleton_method(as) { |*args, **options| public_send(name).call(*args, **options) }
    end

    def record_port(name)
      Hubs.add(self)
      declared_ports << name
      record_ports << name
      singleton_class.attr_reader name
      define_singleton_method(:"#{name}=") { |model| fill_record_port(name, model) }
    end

    def link_record(name, model_and_link, &link)
      links_to(name)[model_and_link] = link
      filling = public_send(name)
      link.call(filling) if active_record_model?(filling)
    end

    def port_names = declared_ports.dup

    def unwired_ports
      declared_ports.reject { |name| instance_variable_get(:"@#{name}") }.map { |name| unwired_message(name) }
    end

    def uncallable_ports
      (declared_ports - record_ports).select { |name| instance_variable_get(:"@#{name}")&.respond_to?(:call) == false }
        .map { |name| "#{hub_name} #{name.to_s.tr("_", " ")} is filled with something that cannot be called" }
    end

    def unmodelled_ports
      record_ports.select { |name| instance_variable_get(:"@#{name}") }
        .reject { |name| active_record_model?(instance_variable_get(:"@#{name}")) }
        .map { |name| "#{hub_name} #{name.to_s.tr("_", " ")} is filled with something that is not an Active Record model" }
    end

    private

    def declared_ports = @declared_ports ||= []

    def record_ports = @record_ports ||= []

    def links_to(name) = (@record_links ||= {})[name] ||= {}

    def fill_record_port(name, model)
      instance_variable_set(:"@#{name}", model)
      links_to(name).each_value { |link| link.call(model) } if active_record_model?(model)
    end

    def active_record_model?(filling) = filling.is_a?(Class) && filling < ActiveRecord::Base

    def unwired(name)
      ->(*, **) { raise UnwiredPortError, unwired_message(name) }
    end

    def unwired_message(name) = "#{hub_name} #{name.to_s.tr("_", " ")} is not wired"

    def hub_name = self.name.demodulize.then { |hub| hub.end_with?("s") ? "#{hub}'" : "#{hub}'s" }
  end
end
