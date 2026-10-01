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
  end
end
