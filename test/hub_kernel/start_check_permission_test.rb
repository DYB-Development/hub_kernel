require "test_helper"

module HubKernel
  class StartCheckPermissionTest < ActiveSupport::TestCase
    module Shop
      extend HubKernel::Exposes

      exposes :price_of, takes: %i[item], writes: false

      def self.price_of(item:) = item
    end

    setup do
      @registered, @exposing = HubKernel::Hubs.registered.dup, HubKernel::Interface::ExposingHubs.list.dup
      @check, @scope = HubKernel::Authz.check, HubKernel::Context.scope
      HubKernel::Hubs.registered.clear
      HubKernel::Interface::ExposingHubs.list.replace([ Shop ])
      HubKernel::Authz.check = ->(*) { true }
      HubKernel::Context.scope = ->(_account, &call) { call.call }
    end

    teardown do
      HubKernel::Hubs.registered.replace(@registered)
      HubKernel::Interface::ExposingHubs.list.replace(@exposing)
      HubKernel::Authz.check, HubKernel::Context.scope = @check, @scope
    end

    test "an app whose hubs expose a method refuses to start without the permission check and names it" do
      HubKernel::Authz.check = nil

      assert_raises(HubKernel::UnwiredPortError, match: "hub_kernel's permission check is not filled") { HubKernel::Hubs.check! }
    end

    test "an app whose hubs expose a method refuses to start without the account scope and names it" do
      HubKernel::Context.scope = nil

      assert_raises(HubKernel::UnwiredPortError, match: "hub_kernel's account scope is not filled") { HubKernel::Hubs.check! }
    end

    test "a hub that exposes a method is listed for the start check" do
      HubKernel::Interface::ExposingHubs.list.clear
      Module.new { extend HubKernel::Exposes }.tap { |hub| hub.define_singleton_method(:name) { "Pantry" } }.exposes(:count, takes: [], writes: false)

      assert_equal [ "Pantry" ], HubKernel::Hubs.list.map(&:name)
    end

    test "an app whose hubs expose nothing starts without the permission check or the account scope" do
      HubKernel::Interface::ExposingHubs.list.replace([ Module.new { extend HubKernel::Exposes } ])
      HubKernel::Authz.check, HubKernel::Context.scope = nil, nil

      assert_nothing_raised { HubKernel::Hubs.check! }
    end

    test "a permission check filled with something that cannot be called is named" do
      HubKernel::Authz.check = "allow everyone"

      assert_raises(HubKernel::UnwiredPortError, match: "hub_kernel's permission check is filled with something that cannot be called") { HubKernel::Hubs.check! }
    end
  end
end
