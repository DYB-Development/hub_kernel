module HubKernel
  class UnexposedMethodError < StandardError; end

  module Exposes
    Exposed = Data.define(:name, :takes, :writes)

    def exposes(name, takes:, writes:)
      exposed_methods[name.to_s] = Exposed.new(name: name, takes: takes, writes: writes)
    end

    def exposed(name) = exposed_methods[name.to_s]

    def call_exposed(name, values:, person:, account:)
      exposure = exposed(name) || raise(UnexposedMethodError, "#{exposing_hub} does not expose #{name}")
      public_send(exposure.name, **values)
    end

    def exposure_problems
      exposed_methods.values.filter_map { |exposure| exposure_problem(exposure) }
    end

    private

    def exposed_methods = @exposed_methods ||= {}

    def exposing_hub = name.demodulize

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
