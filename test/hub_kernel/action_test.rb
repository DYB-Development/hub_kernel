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

    test "an action refuses to be built without the person" do
      error = assert_raises(ArgumentError) do
        ExampleAction.new(account: :an_account, values: {})
      end

      assert_match(/person/, error.message)
    end

    test "an action refuses to be built without the account" do
      error = assert_raises(ArgumentError) do
        ExampleAction.new(person: :a_person, values: {})
      end

      assert_match(/account/, error.message)
    end

    test "an action refuses to be built without the values" do
      error = assert_raises(ArgumentError) do
        ExampleAction.new(person: :a_person, account: :an_account)
      end

      assert_match(/values/, error.message)
    end
  end
end
