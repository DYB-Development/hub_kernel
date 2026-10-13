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
end
