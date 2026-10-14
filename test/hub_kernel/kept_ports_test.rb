require "test_helper"
require "hub_kernel/kept_ports"

module HubKernel
  class KeptPortsTest < ActiveSupport::TestCase
    module Sales
      extend HubKernel::Ports

      port :person_chooser, as: :person_choices
      port :payment_lister, as: :payments_on
    end

    module Finance
      extend HubKernel::Ports

      port :job_chooser, as: :job_choices
    end

    module Fulfillment
      extend HubKernel::Ports

      record_port :job_record
    end

    class Job < ActiveRecord::Base
    end

    class Order < ActiveRecord::Base
    end

    teardown do
      Sales.person_chooser = nil
      Sales.payment_lister = nil
      Finance.job_chooser = nil
      Fulfillment.job_record = nil
    end

    test "every port of each hub a test names is filled after the test as it was before it" do
      person_chooser = -> { [] }
      job_chooser = -> { [] }
      Sales.person_chooser = person_chooser
      Finance.job_chooser = job_chooser

      run_test_keeping(Sales, Finance) do
        Sales.person_chooser = -> { [ :changed ] }
        Sales.payment_lister = -> { [ :changed ] }
        Finance.job_chooser = nil
      end

      assert_equal [ person_chooser, [ "Sales' payment lister is not wired" ], job_chooser ], [ Sales.person_chooser, Sales.unwired_ports, Finance.job_chooser ]
    end

    test "a port a test empties or replaces holds the change while the test runs and its old filling after" do
      person_chooser = -> { [] }
      replacement = -> { [ :replaced ] }
      Sales.person_chooser = person_chooser
      Sales.payment_lister = person_chooser
      during = nil

      run_test_keeping(Sales) do
        Sales.person_chooser = replacement
        Sales.payment_lister = nil
        during = [ Sales.person_chooser, Sales.unwired_ports ]
      end

      assert_equal [ [ replacement, [ "Sales' payment lister is not wired" ] ], [ person_chooser, [] ] ], [ during, [ Sales.person_chooser, Sales.unwired_ports ] ]
    end

    test "a record port holds the model it held before the test after the test" do
      Fulfillment.job_record = Job

      run_test_keeping(Fulfillment) { Fulfillment.job_record = Order }

      assert_equal Job, Fulfillment.job_record
    end

    private

    def run_test_keeping(*hubs, &body)
      test_case = Class.new(ActiveSupport::TestCase) { include HubKernel::KeptPorts }
      Minitest::Runnable.runnables.delete(test_case)
      test_case.keep_ports { hubs }
      test_case.define_method(:test_changing_ports) { instance_exec(&body); pass }
      test_case.new("test_changing_ports").run
    end
  end
end
