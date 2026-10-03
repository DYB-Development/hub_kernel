require "test_helper"

module HubKernel
  class CallExposedTest < ActiveSupport::TestCase
    module Shop
      extend HubKernel::Exposes

      exposes :price_of, takes: %i[item], writes: false

      def self.price_of(item:) = "#{item} costs 3"

      exposes :label, takes: %i[item], writes: false

      def self.label(**values) = values
    end

    test "calling an exposed method by name runs it and returns its answer" do
      assert_equal "soap costs 3", Shop.call_exposed("price_of", values: { item: "soap" }, person: :sam, account: :acme)
    end

    test "calling a name the hub does not expose raises an error naming the hub and the name" do
      assert_raises(HubKernel::UnexposedMethodError, match: "Shop does not expose restock") { Shop.call_exposed("restock", values: {}, person: :sam, account: :acme) }
    end

    test "a call missing a value the method requires raises the missing-value error naming it" do
      assert_raises(HubKernel::MissingArgumentError, match: "Give item") { Shop.call_exposed("price_of", values: {}, person: :sam, account: :acme) }
    end

    test "a value the method is not listed with is left out of the call" do
      assert_equal({ item: "soap" }, Shop.call_exposed("label", values: { item: "soap", colour: "red" }, person: :sam, account: :acme))
    end

    test "a call that names no person is refused before the method runs" do
      assert_raises(HubKernel::MissingArgumentError, match: "A call by name needs a person") { Shop.call_exposed("price_of", values: { item: "soap" }, person: nil, account: :acme) }
    end
  end
end
