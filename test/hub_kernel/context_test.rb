require "test_helper"
require "hub_kernel/context"

module HubKernel
  class ContextTest < ActiveSupport::TestCase
    test "the null context returns a fixed actor" do
      assert_equal :null_actor, HubKernel::Context::Null.new.actor
    end

    test "the null context returns a fixed tenant" do
      assert_equal :null_tenant, HubKernel::Context::Null.new.tenant
    end
  end
end
