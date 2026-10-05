require "hub_kernel/action"
require "hub_kernel/authz"
require "hub_kernel/context"
require "hub_kernel/ports"

module HubKernel
  class UnexposedMethodError < StandardError; end
  class Refused < StandardError; end

  module Exposes
    Exposed = Data.define(:name, :takes, :writes)

    def exposes(name, takes:, writes:)
      exposed_methods[name.to_s] = Exposed.new(name: name, takes: takes, writes: writes)
    end

    def exposed(name) = exposed_methods[name.to_s]

    def call_exposed(name, values:, person:, account:)
      raise MissingArgumentError, "A call by name needs a person" if person.nil?
      raise MissingArgumentError, "A call by name needs an account" if account.nil?

      exposure = exposed(name) || raise(UnexposedMethodError, "#{exposing_hub} does not expose #{name}")
      refuse_unless_allowed(exposure, person, account)
      refuse_missing_values(exposure, values)
      within_account(account) { public_send(exposure.name, **values.slice(*exposure.takes)) }
    end

    def exposure_problems
      exposed_methods.values.filter_map { |exposure| exposure_problem(exposure) }
    end

    private

    def exposed_methods = @exposed_methods ||= {}

    def exposing_hub = name.demodulize

    def refuse_unless_allowed(exposure, person, account)
      raise UnwiredPortError, "hub_kernel's permission check is not filled" unless Authz.check

      answer = Authz.check.call(person, "#{exposing_hub.underscore}:#{exposure.name}", account)
      raise NonBooleanAnswerError, "The permission check must answer true or false, got #{answer.inspect}" unless [ true, false ].include?(answer)
      raise NotAllowed, "#{exposing_hub} #{exposure.name}" unless answer
    end

    def within_account(account, &call)
      raise UnwiredPortError, "hub_kernel's account scope is not filled" unless Context.scope

      Context.scope.call(account, &call)
    end

    def refuse_missing_values(exposure, values)
      missing = keywords(exposure, :keyreq) - values.keys
      raise MissingArgumentError, "Give #{missing.join(", ")}" if missing.any?
    end

    def exposure_problem(exposure)
      return "#{exposing_hub} exposes #{exposure.name}, which it has no method for" unless respond_to?(exposure.name)
      return if takes_listed_values?(exposure)

      "#{exposing_hub} exposes #{exposure.name} with #{exposure.takes.join(", ")}, but it takes #{keywords(exposure, :keyreq, :key).join(", ")}"
    end

    def takes_listed_values?(exposure)
      (keywords(exposure, :keyreq) - exposure.takes).empty? && (takes_any_values?(exposure) || (exposure.takes - keywords(exposure, :keyreq, :key)).empty?)
    end

    def takes_any_values?(exposure) = method(exposure.name).parameters.any? { |kind, _| kind == :keyrest }

    def keywords(exposure, *kinds) = method(exposure.name).parameters.filter_map { |kind, value| value if kinds.include?(kind) }
  end
end
