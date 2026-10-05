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

      private

      def write(root, path, source)
        FileUtils.mkdir_p(File.dirname(File.join(root, path)))
        File.write(File.join(root, path), source)
      end

      def crossing_check_failure(root, **options) = crossing_check_run(root, **options).failures.first&.message

      def crossing_check_run(root, test: "no file names a class another hub owns", owners: OWNERS, **options)
        check = Class.new(ActiveSupport::TestCase) { include HubKernel::Conformance::Crossings }
        Minitest::Runnable.runnables.delete(check)
        check.crossings(root: root, **options) { HubKernel::Crossings.new(owners: owners) }
        check.new("test_#{test.tr(" ", "_")}").run
      end
    end
  end
end
