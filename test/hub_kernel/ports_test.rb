require "test_helper"
require "hub_kernel/ports"
require "open3"

module HubKernel
  class PortsTest < ActiveSupport::TestCase
    module Supplies
      extend HubKernel::Ports

      port :spend_recorder, as: :record_spend
    end

    module Finance
      extend HubKernel::Ports

      port :job_chooser, as: :job_choices
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

    test "the unfilled port error names a hub not ending in s with an apostrophe s" do
      assert_raises(HubKernel::UnwiredPortError, match: "Finance's job chooser is not wired") do
        Finance.job_choices
      end
    end

    test "an app that requires hub_kernel can declare ports with no further require" do
      script = 'require "rails"; require "hub_kernel"; module Sales; extend HubKernel::Ports; port :namer, as: :name_of; end; print "declared"'
      output, = Open3.capture2e(RbConfig.ruby, "-I", File.expand_path("../../lib", __dir__), "-e", script)

      assert_equal "declared", output
    end
  end
end
