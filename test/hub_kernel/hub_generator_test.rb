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

    test "a namespaced hub is generated at the matching nested path" do
      run_generator [ "Console::Hubs::Billing" ]

      assert_file "app/models/console/hubs/billing.rb", /module Console::Hubs::Billing\n/
    end

    test "a namespaced hub's test is generated at the matching nested path" do
      run_generator [ "Console::Hubs::Billing" ]

      assert_file "test/models/console/hubs/billing_test.rb", /class Console::Hubs::BillingTest < ActiveSupport::TestCase\n/
    end

    test "a generated hub loads and calls whatever the app filled its port with" do
      run_generator [ "GeneratedLedger", "entry_recorder:record_entry" ]
      load File.join(destination_root, "app/models/generated_ledger.rb")
      GeneratedLedger.entry_recorder = ->(amount:) { amount }

      assert_equal 5, GeneratedLedger.record_entry(amount: 5)
    ensure
      HubKernel::Hubs.list.reject! { |hub| hub.name == "GeneratedLedger" }
      Object.send(:remove_const, :GeneratedLedger) if Object.const_defined?(:GeneratedLedger)
    end

    test "a hub generated inside a gem adds hub_kernel to the gem's gemspec" do
      write_gemspec
      run_generator [ "Billing" ]

      assert_file "billing.gemspec", /  spec.add_dependency "hub_kernel", "~> #{HubKernel::VERSION[/\A\d+\.\d+/]}"\nend/
    end

    test "a second hub generated inside the same gem does not add hub_kernel twice" do
      write_gemspec
      run_generator [ "Billing" ]
      run_generator [ "Invoicing" ]

      assert_equal 1, File.read(File.join(destination_root, "billing.gemspec")).scan('add_dependency "hub_kernel"').size
    end

    test "a hub generated inside a gem gets no hub check in the gem's own tests" do
      write_gemspec
      run_generator [ "Billing" ]

      assert_no_file "test/models/billing_test.rb"
    end

    private

    def write_gemspec
      File.write(File.join(destination_root, "billing.gemspec"), <<~RUBY)
        Gem::Specification.new do |spec|
          spec.name = "billing"
          spec.add_dependency "rails", ">= 8.1"
        end
      RUBY
    end
  end
end
