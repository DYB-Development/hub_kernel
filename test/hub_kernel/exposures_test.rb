require "test_helper"

module HubKernel
  class ExposuresTest < ActiveSupport::TestCase
    module Shop
      extend HubKernel::Exposes

      exposes :price_of, takes: %i[item], writes: false
      exposes :restock, takes: %i[item], writes: true

      def self.price_of(item:) = item

      def self.restock(item:) = item
    end

    setup { @check = HubKernel::Authz.check }
    teardown { HubKernel::Authz.check = @check }

    test "a hub gives every exposed entry with its name, the values it takes and whether it writes" do
      assert_equal [ [ :price_of, %i[item], false ], [ :restock, %i[item], true ] ], Shop.exposures.map { |exposure| [ exposure.name, exposure.takes, exposure.writes ] }
    end

    test "a hub gives only the entries the host's permission check allows a person on an account" do
      HubKernel::Authz.check = ->(person, action, account) { person == :sam && account == :acme && action == "shop:price_of" }

      assert_equal [ :price_of ], Shop.exposures_for(person: :sam, account: :acme).map(&:name)
    end
  end
end
