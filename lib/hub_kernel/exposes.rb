module HubKernel
  module Exposes
    Exposed = Data.define(:name, :takes, :writes)

    def exposes(name, takes:, writes:)
      exposed_methods[name.to_s] = Exposed.new(name: name, takes: takes, writes: writes)
    end

    def exposed(name) = exposed_methods[name.to_s]

    def exposure_problems
      exposed_methods.values.reject { |method| respond_to?(method.name) }.map { |method| "#{exposing_hub} exposes #{method.name}, which it has no method for" }
    end

    private

    def exposed_methods = @exposed_methods ||= {}

    def exposing_hub = name.demodulize
  end
end
