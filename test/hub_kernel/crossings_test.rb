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

    test "a hub naming another hub's interface module is a crossing" do
      crossings = HubKernel::Crossings.new(owners: OWNERS, interfaces: { finance: "Shop::Hubs::Finance" })

      assert_equal [ "Shop::Hubs::Finance" ], crossings.in("app/models/shop/purchase.rb", "Shop::Hubs::Finance.record_spend(amount: 5)")
    end

    test "the host's layer may name any hub's interface module" do
      crossings = HubKernel::Crossings.new(owners: { console: %w[Shop::Judgement] }, host_layer: :console, interfaces: { finance: "Shop::Hubs::Finance" })

      assert_empty crossings.in("app/models/shop/judgement.rb", "Shop::Hubs::Finance.balance")
    end

    test "a file belongs to the map when a hub owns it" do
      crossings = HubKernel::Crossings.new(owners: OWNERS)

      assert_equal [ true, false ], [ crossings.belongs?("app/models/shop/purchase.rb"), crossings.belongs?("app/models/billing/invoice.rb") ]
    end

    test "the classes no hub owns are named from the files given" do
      crossings = HubKernel::Crossings.new(owners: OWNERS)
      paths = [ "app/models/shop/purchase.rb", "app/models/shop/refund.rb", "app/views/shop/refunds/index.html.erb" ]

      assert_equal [ "Shop::Refund" ], crossings.unowned_classes(paths)
    end

    test "a class the map gives to two hubs is named" do
      crossings = HubKernel::Crossings.new(owners: { supplies: %w[Shop::Purchase Shop::Receipt], finance: %w[Shop::Expense Shop::Receipt] })

      assert_equal [ "Shop::Receipt" ], crossings.claimed_twice
    end

    test "a class the map names that does not exist is named" do
      crossings = HubKernel::Crossings.new(owners: { supplies: %w[HubKernel::Crossings Shop::Ghost] })

      assert_equal [ "Shop::Ghost" ], crossings.missing_classes
    end

    test "naming a class under another hub's namespace is a crossing" do
      crossings = HubKernel::Crossings.new(owners: OWNERS, namespaces: { billing: %w[Billing] })

      assert_equal [ "Billing::Invoice" ], crossings.in("app/models/shop/purchase.rb", "Billing::Invoice.create!(amount: 5)")
    end

    test "a file under a hub's namespace belongs to that hub" do
      crossings = HubKernel::Crossings.new(owners: OWNERS, namespaces: { billing: %w[Billing] })

      assert_empty crossings.in("app/models/billing/invoice.rb", "Billing::Payment.where(invoice: self)")
    end

    test "a class listed by name belongs to its hub even under another hub's namespace" do
      crossings = HubKernel::Crossings.new(owners: { supplies: %w[Shop::Purchase Billing::Refund] }, namespaces: { billing: %w[Billing] })

      assert_equal [ "Billing::Refund" ], crossings.in("app/models/billing/invoice.rb", "Billing::Refund.for(self)")
    end
  end
end
