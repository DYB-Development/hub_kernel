require "test_helper"
require "hub_kernel/action"

module HubKernel
  class ActionTest < ActiveSupport::TestCase
    class ExampleAction
      include HubKernel::Action
    end

    test "an action takes the person, the account and the submitted values" do
      action = ExampleAction.new(person: :a_person, account: :an_account, values: { name: "Pretend Name" })

      assert_equal :a_person, action.person
    end
  end
end
