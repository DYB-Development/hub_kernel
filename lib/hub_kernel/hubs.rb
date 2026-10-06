require "hub_kernel/authz"

module HubKernel
  module Hubs
    def self.add(hub)
      list.reject! { |listed| listed.name == hub.name }
      list << hub
    end

    def self.list = @list ||= []

    def self.check!
      unwired = list.select { |hub| hub.respond_to?(:unwired_ports) }.flat_map(&:unwired_ports) + unfilled_host_answers
      raise UnwiredPortError, unwired.join("\n") if unwired.any?
    end

    def self.unfilled_host_answers
      return [] unless list.any? { |hub| hub.respond_to?(:exposures) && hub.exposures.any? }

      Authz.check ? [] : [ "hub_kernel's permission check is not filled" ]
    end
    private_class_method :unfilled_host_answers
  end
end
