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
  end
end
