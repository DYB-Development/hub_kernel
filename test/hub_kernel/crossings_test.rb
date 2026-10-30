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

    test "a class name inside a double-quoted string in a Ruby file is not a crossing" do
      crossings = HubKernel::Crossings.new(owners: OWNERS)

      assert_empty crossings.in("app/models/shop/purchase.rb", %(SECTIONS = { "Shop::Expense" => %i[expenses] }))
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

    test "naming a constant inside a class under another hub's namespace names that class" do
      crossings = HubKernel::Crossings.new(owners: OWNERS, namespaces: { billing: %w[Billing] })

      assert_equal [ "Billing::Invoice" ], crossings.in("app/models/shop/purchase.rb", "Billing::Invoice::KINDS.first")
    end

    test "a file under a hub's folder belongs to that hub without being on any list" do
      crossings = HubKernel::Crossings.new(owners: {})

      assert crossings.belongs?("hubs/supplies/app/models/shop/purchase.rb")
    end

    test "a file in one hub's folder that names a class defined in another hub's folder names a crossing" do
      crossings = HubKernel::Crossings.new(owners: {}, folder_files: [ "hubs/finance/app/models/shop/expense.rb" ])

      assert_equal [ "Shop::Expense" ], crossings.in("hubs/supplies/app/models/shop/purchase.rb", "Shop::Expense.create!(name: name)")
    end

    test "a class defined in a hub's folder is not reported as owned by no hub" do
      crossings = HubKernel::Crossings.new(owners: {})

      assert_empty crossings.unowned_classes([ "hubs/supplies/app/models/shop/purchase.rb" ])
    end

    test "the crossing check runs when the host passes no list of class names" do
      crossings = HubKernel::Crossings.new(folder_files: [ "hubs/finance/app/models/shop/expense.rb" ])

      assert_equal [ "Shop::Expense" ], crossings.in("hubs/supplies/app/models/shop/purchase.rb", "Shop::Expense.create!(name: name)")
    end

    test "a file in a hub's folder that names a class from the same folder names no crossing" do
      crossings = HubKernel::Crossings.new(folder_files: [ "hubs/supplies/app/models/shop/consumable.rb" ])

      assert_empty crossings.in("hubs/supplies/app/models/shop/purchase.rb", "Shop::Consumable.find(id)")
    end

    test "a file in a hub's folder that names a class the host's list gives another hub names a crossing" do
      crossings = HubKernel::Crossings.new(owners: OWNERS)

      assert_equal [ "Shop::Expense" ], crossings.in("hubs/supplies/app/models/shop/purchase.rb", "Shop::Expense.create!(name: name)")
    end

    test "a file outside every hub folder that names a class in a hub's folder names a crossing" do
      crossings = HubKernel::Crossings.new(owners: OWNERS, folder_files: [ "hubs/billing/app/models/billing/invoice.rb" ])

      assert_equal [ "Billing::Invoice" ], crossings.in("app/models/shop/purchase.rb", "Billing::Invoice.create!(name: name)")
    end

    test "a class on the shared list named from a hub's folder names no crossing" do
      crossings = HubKernel::Crossings.new(owners: OWNERS, shared: %w[Shop::Expense])

      assert_empty crossings.in("hubs/supplies/app/models/shop/purchase.rb", "Shop::Expense.create!(name: name)")
    end

    test "a file of the host's layer may name the hub module found in a hub's folder" do
      crossings = HubKernel::Crossings.new(owners: { console: %w[Console::Home] }, host_layer: :console)
      crossings.read_hub_modules("hubs/supplies/app/models/console/hubs/supplies.rb" => "module Console::Hubs::Supplies\n  extend HubKernel::Ports\nend\n")

      assert_empty crossings.in("app/models/console/home.rb", "Console::Hubs::Supplies.purchases")
    end

    test "a file in another hub's folder that names a hub module found in a hub's folder names a crossing" do
      crossings = HubKernel::Crossings.new(host_layer: :console)
      crossings.read_hub_modules("hubs/supplies/app/models/console/hubs/supplies.rb" => "module Console::Hubs::Supplies\n  extend HubKernel::Ports\nend\n")

      assert_equal [ "Console::Hubs::Supplies" ], crossings.in("hubs/finance/app/models/shop/expense.rb", "Console::Hubs::Supplies.purchases")
    end

    test "a class the host's list gives one hub while its file sits in another hub's folder is owned twice" do
      crossings = HubKernel::Crossings.new(owners: { supplies: %w[Console::Purchase] }, folder_files: [ "hubs/finance/app/models/console/purchase.rb" ])

      assert_equal [ "Console::Purchase" ], crossings.claimed_twice
    end

    test "a class still on the host's list whose file sits in the folder of the hub it is listed under is reported" do
      crossings = HubKernel::Crossings.new(owners: { supplies: %w[Console::Purchase] }, folder_files: [ "hubs/supplies/app/models/console/purchase.rb" ])

      assert_equal [ "Console::Purchase" ], crossings.listed_in_their_folders
    end

    test "a listed class whose file sits in a hub folder is not reported as missing" do
      crossings = HubKernel::Crossings.new(owners: { supplies: %w[Shop::Ghostly] }, folder_files: [ "hubs/supplies/app/models/shop/ghostly.rb" ])

      assert_empty crossings.missing_classes
    end

    test "a hub folder holding no hub module is found" do
      crossings = HubKernel::Crossings.new(folder_files: [ "hubs/suplies/app/models/shop/purchase.rb" ])

      assert_equal [ "hubs/suplies" ], crossings.folders_without_hub_module
    end

    test "a file of the host's layer may name each of several hub modules found in one hub's folder" do
      crossings = HubKernel::Crossings.new(owners: { console: %w[Console::Home] }, host_layer: :console,
                                           folder_files: %w[hubs/operations/app/models/console/hubs/finance.rb hubs/operations/app/models/console/hubs/supplies.rb])
      crossings.read_hub_modules(
        "hubs/operations/app/models/console/hubs/finance.rb" => "module Console::Hubs::Finance\n  extend HubKernel::Ports\nend\n",
        "hubs/operations/app/models/console/hubs/supplies.rb" => "module Console::Hubs::Supplies\n  extend HubKernel::Exposes\nend\n"
      )

      assert_empty crossings.in("app/models/console/home.rb", "Console::Hubs::Finance.spend; Console::Hubs::Supplies.purchases")
    end

    test "a file in another hub's folder that names any of several hub modules in one folder names a crossing" do
      crossings = HubKernel::Crossings.new(folder_files: %w[hubs/operations/app/models/console/hubs/finance.rb hubs/operations/app/models/console/hubs/supplies.rb])
      crossings.read_hub_modules(
        "hubs/operations/app/models/console/hubs/finance.rb" => "module Console::Hubs::Finance\n  extend HubKernel::Ports\nend\n",
        "hubs/operations/app/models/console/hubs/supplies.rb" => "module Console::Hubs::Supplies\n  extend HubKernel::Exposes\nend\n"
      )

      assert_equal [ "Console::Hubs::Finance" ], crossings.in("hubs/sales/app/models/shop/quote.rb", "Console::Hubs::Finance.spend")
    end

    test "a file in the same hub folder that names another of its hub modules names no crossing" do
      crossings = HubKernel::Crossings.new(folder_files: %w[hubs/operations/app/models/console/hubs/finance.rb hubs/operations/app/models/console/hubs/supplies.rb])
      crossings.read_hub_modules(
        "hubs/operations/app/models/console/hubs/finance.rb" => "module Console::Hubs::Finance\n  extend HubKernel::Ports\nend\n",
        "hubs/operations/app/models/console/hubs/supplies.rb" => "module Console::Hubs::Supplies\n  extend HubKernel::Exposes\nend\n"
      )

      assert_empty crossings.in("hubs/operations/app/models/console/hubs/finance.rb", "Console::Hubs::Supplies.purchases")
    end
  end
end
