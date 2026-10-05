require "test_helper"

module HubKernel
  class HostPermissionTest < ActiveSupport::TestCase
    module Shop
      extend HubKernel::Exposes

      exposes :price_of, takes: %i[item], writes: false

      def self.price_of(item:) = "#{item} costs 3"

      singleton_class.attr_accessor :scoped_to

      exposes :whose_shelf, takes: [], writes: false

      def self.whose_shelf = scoped_to
    end

    setup do
      @check, @scope = HubKernel::Authz.check, HubKernel::Context.scope
      HubKernel::Authz.check = ->(*) { true }
      HubKernel::Context.scope = ->(_account, &call) { call.call }
    end
    teardown { HubKernel::Authz.check, HubKernel::Context.scope = @check, @scope }

    test "the host's permission check is asked with the person, the hub's action and the account" do
      asked = []
      HubKernel::Authz.check = ->(person, action, account) { asked << [ person, action, account ] && true }

      Shop.call_exposed("price_of", values: { item: "soap" }, person: :sam, account: :acme)

      assert_equal [ [ :sam, "shop:price_of", :acme ] ], asked
    end

    test "a call the host's permission check refuses raises the not-allowed error" do
      HubKernel::Authz.check = ->(*) { false }

      assert_raises(HubKernel::NotAllowed) { Shop.call_exposed("price_of", values: { item: "soap" }, person: :sam, account: :acme) }
    end

    test "the host's permission check returning neither true nor false raises the non-boolean answer error" do
      HubKernel::Authz.check = ->(*) { :maybe }

      assert_raises(HubKernel::NonBooleanAnswerError) { Shop.call_exposed("price_of", values: { item: "soap" }, person: :sam, account: :acme) }
    end

    test "a permitted call runs inside the host's account scope for the account it names" do
      HubKernel::Context.scope = ->(account, &call) { Shop.scoped_to = account; call.call.tap { Shop.scoped_to = nil } }

      assert_equal :acme, Shop.call_exposed("whose_shelf", values: {}, person: :sam, account: :acme)
    end

    test "a call made while the permission check is unfilled raises an error naming it" do
      HubKernel::Authz.check = nil

      assert_raises(HubKernel::UnwiredPortError, match: "hub_kernel's permission check is not filled") { Shop.call_exposed("price_of", values: { item: "soap" }, person: :sam, account: :acme) }
    end

    test "a call made while the account scope is unfilled raises an error naming it" do
      HubKernel::Context.scope = nil

      assert_raises(HubKernel::UnwiredPortError, match: "hub_kernel's account scope is not filled") { Shop.call_exposed("price_of", values: { item: "soap" }, person: :sam, account: :acme) }
    end

    test "a refused call is refused before its missing values are checked" do
      HubKernel::Authz.check = ->(*) { false }

      assert_raises(HubKernel::NotAllowed) { Shop.call_exposed("price_of", values: {}, person: :sam, account: :acme) }
    end
  end
end
