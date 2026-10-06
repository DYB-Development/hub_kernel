require "test_helper"

module HubKernel
  class StartCheckPermissionTest < ActiveSupport::TestCase
    module Shop
      extend HubKernel::Exposes

      exposes :price_of, takes: %i[item], writes: false

      def self.price_of(item:) = item
    end

    setup do
      @listed, @check, @scope = HubKernel::Hubs.list.dup, HubKernel::Authz.check, HubKernel::Context.scope
      HubKernel::Hubs.list.replace([ Shop ])
      HubKernel::Authz.check = ->(*) { true }
      HubKernel::Context.scope = ->(_account, &call) { call.call }
    end

    teardown do
      HubKernel::Hubs.list.replace(@listed)
      HubKernel::Authz.check, HubKernel::Context.scope = @check, @scope
    end

    test "an app whose hubs expose a method refuses to start without the permission check and names it" do
      HubKernel::Authz.check = nil

      assert_raises(HubKernel::UnwiredPortError, match: "hub_kernel's permission check is not filled") { HubKernel::Hubs.check! }
    end
  end
end
