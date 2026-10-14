require "test_helper"

class HubKernel::HubFoldersTest < ActiveSupport::TestCase
  test "a model in a hub folder loads by its full class name" do
    assert_equal "Billing::Invoice", "Billing::Invoice".constantize.name
  end

  test "a hub folder's classes load when the host eager-loads its code" do
    Rails.application.eager_load!

    assert_nil Billing.autoload?(:ReminderJob)
  end

  test "a host with no hubs folder adds no hub folders to its load paths" do
    Dir.mktmpdir do |root|
      assert_empty HubKernel::HubFolders.code_paths(Pathname(root))
    end
  end

  test "a class in a hub folder loads when its namespace module is defined in the host's app/models" do
    assert_equal "Storefront::Cart", "Storefront::Cart".constantize.name
  end

  test "an event definition in a hub folder loads by its class name" do
    assert_equal "Billing::InvoiceSent", "Billing::InvoiceSent".constantize.name
  end

  test "files under a hub folder's lib folder are not loaded as code" do
    assert_not Object.const_defined?(:BillingEvents)
  end

  test "the hub folder holding a page's controller is named by its controller path" do
    Dir.mktmpdir do |root|
      write_controller(root, "billing", "billing/invoices")

      assert_equal :billing, HubKernel::HubFolders.hub_of_controller(Pathname(root), "billing/invoices")
    end
  end

  test "no hub folder is named when none holds the page's controller" do
    Dir.mktmpdir do |root|
      write_controller(root, "billing", "billing/invoices")

      assert_nil HubKernel::HubFolders.hub_of_controller(Pathname(root), "accounts/plans")
    end
  end

  test "a controller held by two hub folders raises naming both folders" do
    Dir.mktmpdir do |root|
      write_controller(root, "billing", "plans")
      write_controller(root, "sales", "plans")

      error = assert_raises(HubKernel::HubFolders::SharedController) do
        HubKernel::HubFolders.hub_of_controller(Pathname(root), "plans")
      end
      assert_match %r{hubs/billing.*hubs/sales}, error.message
    end
  end

  test "the hub modules of a host's hub folders are the classes that extend Ports or Exposes" do
    Dir.mktmpdir do |root|
      write_file(root, "hubs/supplies/app/models/supplies.rb", "module Supplies\n  extend HubKernel::Ports\nend\n")
      write_file(root, "hubs/supplies/app/models/supplies/purchase.rb", "class Supplies::Purchase\nend\n")
      write_file(root, "hubs/finance/app/models/finance.rb", "module Finance\n  extend HubKernel::Exposes\nend\n")

      assert_equal %w[Finance Supplies], HubKernel::HubFolders.hub_modules(Pathname(root)).sort
    end
  end

  private

  def write_file(root, path, source)
    file = Pathname(root).join(path)
    FileUtils.mkdir_p(file.dirname)
    file.write(source)
  end

  def write_controller(root, hub, page)
    path = Pathname(root).join("hubs", hub, "app", "controllers", "#{page}_controller.rb")
    FileUtils.mkdir_p(path.dirname)
    FileUtils.touch(path)
  end
end
