require "test_helper"
require "hub_kernel/context"

module HubKernel
  class ContextTest < ActiveSupport::TestCase
    class ExampleHub
      attr_reader :context

      def initialize(context:)
        @context = context
      end
    end

    test "the null context returns a fixed actor" do
      assert_equal :null_actor, HubKernel::Context::Null.new.actor
    end

    test "the null context returns a fixed tenant" do
      assert_equal :null_tenant, HubKernel::Context::Null.new.tenant
    end

    test "a hub reads the current actor through its injected context" do
      hub = ExampleHub.new(context: HubKernel::Context::Null.new)

      assert_equal :null_actor, hub.context.actor
    end

    test "constructing a hub without a context fails at construction" do
      error = assert_raises(ArgumentError) { ExampleHub.new }

      assert_match(/:context/, error.message)
    end
  end
end
