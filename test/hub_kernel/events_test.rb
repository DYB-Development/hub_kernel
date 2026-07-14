require "test_helper"
require "hub_kernel/events"

module HubKernel
  class EventsTest < ActiveSupport::TestCase
    module ExampleEvents
      extend HubKernel::Events
      extend self

      LeadGenerated = Data.define(:prospect_id)

      def lead_generated(prospect_id:)
        emit(:lead_generated, LeadGenerated.new(prospect_id: prospect_id))
      end
    end

    test "declared events are derived from the vocabulary methods" do
      assert_equal [ :lead_generated ], ExampleEvents.declared_events
    end

    test "emitting a declared event delivers its payload to a wired handler" do
      received = nil
      ExampleEvents.on(:lead_generated) { |event| received = event }

      ExampleEvents.lead_generated(prospect_id: 42)

      assert_equal 42, received.prospect_id
    end
  end
end
