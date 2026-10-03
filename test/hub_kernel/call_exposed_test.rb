require "test_helper"

module HubKernel
  class CallExposedTest < ActiveSupport::TestCase
    module Shop
      extend HubKernel::Exposes

      exposes :price_of, takes: %i[item], writes: false

      def self.price_of(item:) = "#{item} costs 3"
    end

    test "calling an exposed method by name runs it and returns its answer" do
      assert_equal "soap costs 3", Shop.call_exposed("price_of", values: { item: "soap" }, person: :sam, account: :acme)
    end

    test "calling a name the hub does not expose raises an error naming the hub and the name" do
      assert_raises(HubKernel::UnexposedMethodError, match: "Shop does not expose restock") { Shop.call_exposed("restock", values: {}, person: :sam, account: :acme) }
    end
  end
end
