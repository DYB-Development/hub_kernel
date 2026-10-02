require "test_helper"
require "hub_kernel/crossings"

module HubKernel
  class CrossingsTest < ActiveSupport::TestCase
    OWNERS = {
      supplies: %w[Shop::Purchase Shop::Consumable],
      finance: %w[Shop::Expense]
    }.freeze

    test "a file names a crossing when it names a class another hub owns" do
      crossings = HubKernel::Crossings.new(owners: OWNERS)

      assert_equal [ "Shop::Expense" ], crossings.in("app/models/shop/purchase.rb", "Shop::Expense.create!(name: name)")
    end

    test "naming a constant inside another hub's class names that class" do
      crossings = HubKernel::Crossings.new(owners: OWNERS)

      assert_equal [ "Shop::Expense" ], crossings.in("app/models/shop/purchase.rb", "Shop::Expense::KINDS.first")
    end

    test "naming a namespace no hub owns is not a crossing" do
      crossings = HubKernel::Crossings.new(owners: OWNERS)

      assert_empty crossings.in("app/models/shop/purchase.rb", "Shop.table_name_prefix")
    end
  end
end
