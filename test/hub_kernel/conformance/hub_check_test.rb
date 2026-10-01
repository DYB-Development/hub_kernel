require "test_helper"
require "hub_kernel/conformance/hub"

module HubKernel
  module Conformance
    class HubCheckTest < ActiveSupport::TestCase
      module Sales
        extend HubKernel::Ports

        port :person_chooser, as: :person_choices
        port :payment_lister, as: :payments_on
      end

      teardown do
        Sales.person_chooser = nil
        Sales.payment_lister = nil
      end

      test "the hub check fails and names each port the app left unfilled" do
        Sales.person_chooser = -> { [] }

        assert_equal "Sales' payment lister is not wired", hub_check_failure(Sales)
      end

      private

      def hub_check_failure(hub)
        check = Class.new(ActiveSupport::TestCase) { include HubKernel::Conformance::Hub }
        Minitest::Runnable.runnables.delete(check)
        check.hub { hub }
        check.runnable_methods.filter_map { |name| check.new(name).run.failures.first&.message }.first
      end
    end
  end
end
