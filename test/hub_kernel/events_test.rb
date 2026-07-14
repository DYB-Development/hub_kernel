require "test_helper"
require "hub_kernel/events"

module HubKernel
  class EventsTest < ActiveSupport::TestCase
    module ExampleEvents
      extend HubKernel::Events
      def lead_generated(prospect_id:); end
    end

    test "declared events are derived from the vocabulary methods" do
      assert_equal [ :lead_generated ], ExampleEvents.declared_events
    end
  end
end
