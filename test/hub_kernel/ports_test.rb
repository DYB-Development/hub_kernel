require "test_helper"
require "hub_kernel/ports"

module HubKernel
  class PortsTest < ActiveSupport::TestCase
    module Supplies
      extend HubKernel::Ports

      port :spend_recorder, as: :record_spend
    end

    teardown do
      Supplies.spend_recorder = nil
    end

    test "calling a filled port returns the answer of what the app filled it with" do
      Supplies.spend_recorder = ->(**) { 41 }

      assert_equal 41, Supplies.record_spend(amount: 5)
    end

    test "the caller's arguments reach whatever the app filled a port with" do
      Supplies.spend_recorder = ->(*args, **options) { [ args, options ] }

      assert_equal [ [ :supplies ], { amount: 5 } ], Supplies.record_spend(:supplies, amount: 5)
    end

    test "an error raised by whatever filled a port reaches the caller unchanged" do
      refusal = Class.new(StandardError)
      Supplies.spend_recorder = ->(**) { raise refusal, "the card is closed" }

      assert_raises(refusal, match: "the card is closed") { Supplies.record_spend(amount: 5) }
    end

    test "calling a port the app left unfilled raises an error naming the hub and the port" do
      assert_raises(HubKernel::UnwiredPortError, match: "Supplies' spend recorder is not wired") do
        Supplies.record_spend(amount: 5)
      end
    end
  end
end
