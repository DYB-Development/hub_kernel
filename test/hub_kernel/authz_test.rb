require "test_helper"
require "hub_kernel/authz"

module HubKernel
  class AuthzTest < ActiveSupport::TestCase
    class FixedAnswerPolicy
      def initialize(answer)
        @answer = answer
      end

      def allowed?(_actor, _action)
        @answer
      end
    end

    class ExampleHub
      include HubKernel::Authz

      gates "campaigns:send"

      def initialize(authz:)
        @authz = authz
      end

      private

      attr_reader :authz
    end

    test "the hub returns the policy's affirmative answer" do
      hub = ExampleHub.new(authz: FixedAnswerPolicy.new(true))

      assert_equal true, hub.allowed?(:actor, "campaigns:send")
    end

    test "the hub returns the policy's negative answer" do
      hub = ExampleHub.new(authz: FixedAnswerPolicy.new(false))

      assert_equal false, hub.allowed?(:actor, "campaigns:send")
    end

    test "a truthy-ish answer from the policy raises" do
      hub = ExampleHub.new(authz: FixedAnswerPolicy.new("yes"))

      assert_raises(HubKernel::NonBooleanAnswerError) { hub.allowed?(:actor, "campaigns:send") }
    end

    test "the non-boolean-answer error states that allowed? must return true or false" do
      hub = ExampleHub.new(authz: FixedAnswerPolicy.new("yes"))

      error = assert_raises(HubKernel::NonBooleanAnswerError) { hub.allowed?(:actor, "campaigns:send") }

      assert_match(/allowed\? must return true or false/, error.message)
    end

    test "constructing a hub without an authz policy fails at construction" do
      error = assert_raises(ArgumentError) { ExampleHub.new }

      assert_match(/:authz/, error.message)
    end

    test "the hub declares the actions it gates" do
      assert_equal [ "campaigns:send" ], ExampleHub.gated_actions
    end
  end
end
