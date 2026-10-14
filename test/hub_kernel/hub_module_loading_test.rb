require "test_helper"

class HubKernel::HubModuleLoadingTest < ActiveSupport::TestCase
  test "a hub module in a hub folder that nothing else loads is checked by the start check at boot" do
    error = assert_raises(HubKernel::UnwiredPortError) { HubKernel::Hubs.check! }

    assert_match "Pantry's shelf counter is not wired", error.message
  end
end
