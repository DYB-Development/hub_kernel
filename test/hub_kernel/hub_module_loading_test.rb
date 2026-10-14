require "test_helper"

class HubKernel::HubModuleLoadingTest < ActiveSupport::TestCase
  test "a hub module in a hub folder that nothing else loads is checked by the start check at boot" do
    error = assert_raises(HubKernel::UnwiredPortError) { HubKernel::Hubs.check! }

    assert_match "Pantry's shelf counter is not wired", error.message
  end

  test "a hub module in a hub folder that nothing else loads and that exposes a method is served by default" do
    assert_equal "Larder", HubKernel::Interface.find("larder")&.name
  end

  test "every hub module in a hub folder is loaded before the host's own boot code fills ports" do
    assert_equal %w[Larder Pantry], (HUBS_SEEN_BY_HOST & %w[Larder Pantry]).sort
  end
end
