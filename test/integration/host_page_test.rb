require "test_helper"

class HostPageTest < ActionDispatch::IntegrationTest
  test "a host's page submits the gem's markup to the host's own address" do
    get "/profile"

    assert_select "form[action=?]", "/profile"
  end

  test "submitting the markup at the host's address shows the saved value on the host's page" do
    patch "/profile", params: {name: "Renamed Person"}

    assert_select "input[name=name][value=?]", "Renamed Person"
  end
end
