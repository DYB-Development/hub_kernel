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

          assert_nil crossing_check_failure(root, files: "app/models/shop/**/*.rb")
        end
      end

      private

      def write(root, path, source)
        FileUtils.mkdir_p(File.dirname(File.join(root, path)))
        File.write(File.join(root, path), source)
      end

      def crossing_check_failure(root, **options)
        check = Class.new(ActiveSupport::TestCase) { include HubKernel::Conformance::Crossings }
        Minitest::Runnable.runnables.delete(check)
        check.crossings(root: root, **options) { HubKernel::Crossings.new(owners: OWNERS) }
        check.runnable_methods.filter_map { |name| check.new(name).run.failures.first&.message }.first
      end
    end
  end
end
