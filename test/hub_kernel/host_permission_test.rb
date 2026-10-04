require "test_helper"

module HubKernel
  class HostPermissionTest < ActiveSupport::TestCase
    module Shop
      extend HubKernel::Exposes

      exposes :price_of, takes: %i[item], writes: false

      def self.price_of(item:) = "#{item} costs 3"
    end

    setup { @check = HubKernel::Authz.check }
    teardown { HubKernel::Authz.check = @check }

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
  end
end
