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

    test "a hub gives every exposed entry with its name, the values it takes and whether it writes" do
      assert_equal [ [ :price_of, %i[item], false ], [ :restock, %i[item], true ] ], Shop.exposures.map { |exposure| [ exposure.name, exposure.takes, exposure.writes ] }
    end
  end
end
