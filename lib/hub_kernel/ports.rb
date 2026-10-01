require "active_support/core_ext/string/inflections"

module HubKernel
  class UnwiredPortError < StandardError; end

  module Ports
    def port(name, as:)
      singleton_class.attr_writer name
      define_singleton_method(name) { instance_variable_get(:"@#{name}") || unwired(name) }
      define_singleton_method(as) { |*args, **options| public_send(name).call(*args, **options) }
    end

    private

    def unwired(name)
      ->(*, **) { raise UnwiredPortError, "#{hub_name} #{name.to_s.tr("_", " ")} is not wired" }
    end

    def hub_name = self.name.demodulize.then { |hub| hub.end_with?("s") ? "#{hub}'" : "#{hub}'s" }
  end
end
