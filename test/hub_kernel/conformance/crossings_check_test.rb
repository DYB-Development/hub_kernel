require "test_helper"
require "tmpdir"
require "hub_kernel/conformance/crossings"

module HubKernel
  module Conformance
    class CrossingsCheckTest < ActiveSupport::TestCase
      OWNERS = { supplies: %w[Shop::Purchase], finance: %w[Shop::Expense] }.freeze

      test "the crossing check fails and lists each file and the class it names" do
        Dir.mktmpdir do |root|
          write(root, "app/models/shop/purchase.rb", "Shop::Expense.create!(name: name)")

          assert_equal "app/models/shop/purchase.rb names Shop::Expense", crossing_check_failure(root)
        end
      end

      test "the crossing check passes when no file names another hub's class" do
        Dir.mktmpdir do |root|
          write(root, "app/models/shop/purchase.rb", "Shop::Purchase.where(name: name)")

          assert_nil crossing_check_failure(root)
        end
      end

      test "the crossing check reads only the files the host names" do
        Dir.mktmpdir do |root|
          write(root, "app/models/billing/invoice.rb", "Shop::Expense.create!(name: name)")
          write(root, "app/models/shop/purchase.rb", "Shop::Purchase.where(name: name)")

          assert_nil crossing_check_failure(root, files: "app/models/shop/**/*.rb")
        end
      end

      test "the crossing check leaves out the files the host excepts" do
        Dir.mktmpdir do |root|
          write(root, "app/models/shop/hubs.rb", "Shop::Expense")
          write(root, "app/models/shop/purchase.rb", "Shop::Purchase.where(name: name)")

          assert_nil crossing_check_failure(root, except: [ "app/models/shop/hubs.rb" ])
        end
      end

      test "a clean crossing check counts as an assertion" do
        Dir.mktmpdir do |root|
          write(root, "app/models/shop/purchase.rb", "Shop::Purchase.where(name: name)")

          assert_equal 1, crossing_check_run(root).assertions
        end
      end

      test "the crossing check fails when no file it read belongs to the map" do
        Dir.mktmpdir do |root|
          write(root, "app/models/billing/invoice.rb", "Billing::Invoice.where(name: name)")

          assert_equal "The crossing check found no files to read", crossing_check_failure(root)
        end
      end

      test "the crossing check fails and names each class it read that no hub owns" do
        Dir.mktmpdir do |root|
          write(root, "app/models/shop/purchase.rb", "Shop::Purchase.where(name: name)")
          write(root, "app/models/shop/refund.rb", "class Shop::Refund; end")

          assert_equal "No hub owns Shop::Refund", crossing_check_failure(root, test: "every class it reads belongs to a hub")
        end
      end

      test "the crossing check fails and names each class the map gives to two hubs" do
        Dir.mktmpdir do |root|
          owners = { supplies: %w[Shop::Purchase Shop::Receipt], finance: %w[Shop::Expense Shop::Receipt] }

          assert_equal "Two hubs own Shop::Receipt", crossing_check_failure(root, test: "no class belongs to two hubs", owners: owners)
        end
      end

      test "the crossing check fails and names each class the map names that does not exist" do
        Dir.mktmpdir do |root|
          owners = { supplies: %w[HubKernel::Crossings Shop::Ghost] }

          assert_equal "The map names Shop::Ghost, which does not exist", crossing_check_failure(root, test: "every class the map names exists", owners: owners)
        end
      end

      test "the crossing check reads every file in a hub's folder by default, helpers included" do
        Dir.mktmpdir do |root|
          write(root, "hubs/finance/app/models/shop/expense.rb", "module Shop; class Expense; end; end")
          write(root, "hubs/supplies/app/helpers/shop/purchases_helper.rb", "Shop::Expense.sum(:amount)")

          assert_equal "hubs/supplies/app/helpers/shop/purchases_helper.rb names Shop::Expense", crossing_check_failure(root, owners: {})
        end
      end

      test "the crossing check finds each hub's interface module in its folder with no interface map passed" do
        Dir.mktmpdir do |root|
          write(root, "hubs/supplies/app/models/shop/hubs/supplies.rb", "module Shop::Hubs::Supplies\n  extend HubKernel::Ports\nend\n")
          write(root, "app/models/shop/home.rb", "Shop::Hubs::Supplies.purchases")

          assert_nil crossing_check_failure(root, owners: { shop: %w[Shop::Home] }, host_layer: :shop)
        end
      end

      test "the crossing check fails naming each listed class already in its hub's folder" do
        Dir.mktmpdir do |root|
          write(root, "hubs/supplies/app/models/shop/purchase.rb", "module Shop; class Purchase; end; end")

          assert_equal "Shop::Purchase sits in its hub's folder, so take it off the list", crossing_check_failure(root, test: "no class is both listed and in its hub's folder")
        end
      end

      test "the crossing check fails naming each hub folder that holds no hub module" do
        Dir.mktmpdir do |root|
          write(root, "hubs/suplies/app/models/shop/purchase.rb", "module Shop; class Purchase; end; end")

          assert_equal "hubs/suplies holds no hub module", crossing_check_failure(root, test: "every hub folder holds a hub module")
        end
      end

      test "the crossing check passes a hub folder that holds a hub module" do
        Dir.mktmpdir do |root|
          write(root, "hubs/supplies/app/models/shop/hubs/supplies.rb", "module Shop::Hubs::Supplies\n  extend HubKernel::Ports\nend\n")

          assert_nil crossing_check_failure(root, test: "every hub folder holds a hub module")
        end
      end

      private

      def write(root, path, source)
        FileUtils.mkdir_p(File.dirname(File.join(root, path)))
        File.write(File.join(root, path), source)
      end

      def crossing_check_failure(root, **options) = crossing_check_run(root, **options).failures.first&.message

      def crossing_check_run(root, test: "no file names a class another hub owns", owners: OWNERS, host_layer: nil, **options)
        check = Class.new(ActiveSupport::TestCase) { include HubKernel::Conformance::Crossings }
        Minitest::Runnable.runnables.delete(check)
        check.crossings(root: root, **options) { HubKernel::Crossings.new(owners: owners, host_layer: host_layer) }
        check.new("test_#{test.tr(" ", "_")}").run
      end
    end
  end
end
