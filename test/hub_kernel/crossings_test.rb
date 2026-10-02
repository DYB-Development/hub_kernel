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

    test "naming a class on the shared list is not a crossing" do
      crossings = HubKernel::Crossings.new(owners: OWNERS, shared: %w[Shop::Expense])

      assert_empty crossings.in("app/models/shop/purchase.rb", "Shop::Expense.create!(name: name)")
    end

    test "a view belongs to the hub that owns its controller" do
      crossings = HubKernel::Crossings.new(owners: { supplies: %w[Shop::Purchase Shop::PurchasesController] })

      assert_empty crossings.in("app/views/shop/purchases/index.html.erb", "<%= Shop::Purchase.count %>")
    end

    test "a view with no controller of its own belongs to the host's layer" do
      crossings = HubKernel::Crossings.new(owners: { supplies: %w[Shop::Purchase], console: %w[Shop::Judgement] }, host_layer: :console)

      assert_empty crossings.in("app/views/shop/home/index.html.erb", "<%= Shop::Judgement.current %>")
    end

    test "a view in a folder named after a record belongs to that record's hub" do
      crossings = HubKernel::Crossings.new(owners: OWNERS, host_layer: :console)

      assert_empty crossings.in("app/views/shop/purchase/_row.html.erb", "<%= Shop::Purchase.model_name %>")
    end
  end
end
