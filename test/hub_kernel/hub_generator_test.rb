require "test_helper"
require "rails/generators/test_case"
require "generators/hub_kernel/hub/hub_generator"

module HubKernel
  class HubGeneratorTest < Rails::Generators::TestCase
    tests HubKernel::Generators::HubGenerator
    destination File.expand_path("../../tmp/generators", __dir__)
    setup :prepare_destination

    test "the generated hub module extends hub_kernel's ports" do
      run_generator [ "Billing" ]

      assert_file "app/models/billing.rb", /module Billing\n  extend HubKernel::Ports\n/
    end

    test "each port named as port and method is declared in the hub module" do
      run_generator [ "Billing", "spend_recorder:record_spend", "job_chooser:job_choices" ]

      assert_file "app/models/billing.rb", /  port :spend_recorder, as: :record_spend\n  port :job_chooser, as: :job_choices\n/
    end

    test "the generated hub test includes hub_kernel's hub check for the hub" do
      run_generator [ "Billing" ]

      assert_file "test/models/billing_test.rb", /class BillingTest < ActiveSupport::TestCase\n  include HubKernel::Conformance::Hub\n\n  hub { Billing }\nend/
    end
  end
end
