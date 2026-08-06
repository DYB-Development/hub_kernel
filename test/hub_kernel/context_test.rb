require "test_helper"
require "hub_kernel/context"

module HubKernel
  class ContextTest < ActiveSupport::TestCase
    test "the null context returns a fixed actor" do
      assert_equal :null_actor, HubKernel::Context::Null.new.actor
    end
  end
end
