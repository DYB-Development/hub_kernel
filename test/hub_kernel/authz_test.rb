require "test_helper"
require "hub_kernel/authz"

module HubKernel
  class AuthzTest < ActiveSupport::TestCase
    test "hub_kernel offers no per-hub list of gated actions" do
      assert_not HubKernel::Authz.const_defined?(:Vocabulary, false)
    end
  end
end
