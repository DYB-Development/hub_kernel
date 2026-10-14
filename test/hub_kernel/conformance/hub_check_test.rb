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

      module Fulfillment
        extend HubKernel::Ports

        record_port :job_record
      end

      class Job < ActiveRecord::Base
      end

      teardown do
        Sales.person_chooser = nil
        Sales.payment_lister = nil
        Fulfillment.job_record = nil
      end

      test "the hub check fails and names each port the app left unfilled" do
        Sales.person_chooser = -> { [] }

        assert_equal "Sales' payment lister is not wired", hub_check_failure(Sales)
      end

      test "a port filled with something that cannot be called fails the hub check and is named" do
        Sales.person_chooser = -> { [] }
        Sales.payment_lister = "the payments page"

        assert_equal "Sales' payment lister is filled with something that cannot be called", hub_check_failure(Sales)
      end

      test "a hub with every port filled with something that can be called passes the hub check" do
        Sales.person_chooser = -> { [] }
        Sales.payment_lister = ->(job_id) { [ job_id ] }

        assert_nil hub_check_failure(Sales)
      end

      test "a record port filled with a model passes the hub check" do
        Fulfillment.job_record = Job

        assert_nil hub_check_failure(Fulfillment)
      end

      test "a record port filled with something that is not a model fails the hub check and is named" do
        Fulfillment.job_record = "Job"

        assert_equal "Fulfillment's job record is filled with something that is not an Active Record model", hub_check_failure(Fulfillment)
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
