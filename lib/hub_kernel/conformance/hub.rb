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
        test "every port of the hub is filled with something that can be called" do
          problems = the_hub.unwired_ports + the_hub.uncallable_ports
          flunk problems.join("\n") if problems.any?
        end
      end
    end
  end
end
