require "test_helper"

class HubFolderViewsTest < ActionDispatch::IntegrationTest
  test "a controller in a hub's folder renders its template from the hub folder's views" do
    get "/billing/statement"

    assert_select "p", "Statement"
  end
end
