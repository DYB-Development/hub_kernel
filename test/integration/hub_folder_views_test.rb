require "test_helper"

class HubFolderViewsTest < ActionDispatch::IntegrationTest
  test "a controller in a hub's folder renders its template from the hub folder's views" do
    get "/billing/statement"

    assert_select "p", "Statement"
  end

  test "a partial in a hub folder's views renders from a host view that calls it by its usual path" do
    get "/receipt"

    assert_select ".statement-summary", "Summary"
  end
end
