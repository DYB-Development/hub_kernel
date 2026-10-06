require "hub_kernel/authz"
require "hub_kernel/context"

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

      { "permission check" => Authz.check, "account scope" => Context.scope }.filter_map { |answer, filled| host_answer_problem(answer, filled) }
    end
    private_class_method :unfilled_host_answers

    def self.host_answer_problem(answer, filled)
      return "hub_kernel's #{answer} is not filled" unless filled

      "hub_kernel's #{answer} is filled with something that cannot be called" unless filled.respond_to?(:call)
    end
    private_class_method :host_answer_problem
  end
end
