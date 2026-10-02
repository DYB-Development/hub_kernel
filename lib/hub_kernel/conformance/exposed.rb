require "active_support/concern"

module HubKernel
  module Conformance
    module Exposed
      extend ActiveSupport::Concern

      class_methods do
        def hub(&block)
          define_method(:the_hub, &block)
        end
      end

      included do
        test "every method the hub exposes exists and takes the values it is listed with" do
          problems = the_hub.exposure_problems
          flunk problems.join("\n") if problems.any?
        end
      end
    end
  end
end
