require "test_helper"

class HostPageTest < ActionDispatch::IntegrationTest
  test "a host's page submits the gem's markup to the host's own address" do
    get "/profile"

    assert_select "form[action=?]", "/profile"
  end
end
