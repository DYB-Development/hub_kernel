require "test_helper"
require "hub_kernel/hubs"

module HubKernel
  class HubsTest < ActiveSupport::TestCase
    module Operations
      extend HubKernel::Ports

      port :resource_namer, as: :resource_names
    end

    test "an app lists every hub that declared a port" do
      assert_includes HubKernel::Hubs.list, Operations
    end

    test "an app with an unfilled port refuses to start and names the port with its hub" do
      assert_raises(HubKernel::UnwiredPortError, match: "Operations' resource namer is not wired") do
        HubKernel::Hubs.check!
      end
    end
  end
end
