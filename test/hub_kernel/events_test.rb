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

    module OtherEvents
      extend HubKernel::Events
      extend self

      LeadGenerated = Data.define(:prospect_id)

      def lead_generated(prospect_id:)
        emit(:lead_generated, LeadGenerated.new(prospect_id: prospect_id))
      end
    end

    teardown do
      ExampleEvents.instance_variable_set(:@handlers, nil)
      OtherEvents.instance_variable_set(:@handlers, nil)
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

    test "multiple handlers on one event fire in wiring order" do
      order = []
      ExampleEvents.on(:lead_generated) { order << :first }
      ExampleEvents.on(:lead_generated) { order << :second }

      ExampleEvents.lead_generated(prospect_id: 1)

      assert_equal [ :first, :second ], order
    end

    test "wiring an undeclared event name raises" do
      assert_raises(HubKernel::UndeclaredEventError) do
        ExampleEvents.on(:not_a_thing) { }
      end
    end

    test "the undeclared-event error names the offending symbol" do
      error = assert_raises(HubKernel::UndeclaredEventError) do
        ExampleEvents.on(:not_a_thing) { }
      end

      assert_match(/not_a_thing/, error.message)
    end

    test "the undeclared-event error lists the declared events" do
      error = assert_raises(HubKernel::UndeclaredEventError) do
        ExampleEvents.on(:not_a_thing) { }
      end

      assert_match(/lead_generated/, error.message)
    end

    test "verify_wired! raises when a declared event has no handler" do
      assert_raises(HubKernel::UnwiredEventError) do
        ExampleEvents.verify_wired!
      end
    end

    test "the unwired-event error names every unwired event" do
      error = assert_raises(HubKernel::UnwiredEventError) do
        ExampleEvents.verify_wired!
      end

      assert_match(/lead_generated/, error.message)
    end

    test "verify_wired! passes when every declared event has a handler" do
      ExampleEvents.on(:lead_generated) { }

      assert_nothing_raised { ExampleEvents.verify_wired! }
    end

    test "each hub keeps an isolated handler table" do
      other_ran = false
      OtherEvents.on(:lead_generated) { other_ran = true }

      ExampleEvents.lead_generated(prospect_id: 1)

      refute other_ran
    end
  end
end
