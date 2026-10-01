require "active_support/concern"

module HubKernel
  module Conformance
    module Hub
      extend ActiveSupport::Concern

      class_methods do
        def hub(&block)
          define_method(:the_hub, &block)
        end
      end

      included do
        test "every port of the hub is filled" do
          unwired = the_hub.unwired_ports
          flunk unwired.join("\n") if unwired.any?
        end
      end
    end
  end
end
