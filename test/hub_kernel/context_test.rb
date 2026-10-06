require "test_helper"
require "hub_kernel/context"

module HubKernel
  class ContextTest < ActiveSupport::TestCase
    test "hub_kernel offers no null context" do
      assert_not HubKernel::Context.const_defined?(:Null, false)
    end
  end
end
