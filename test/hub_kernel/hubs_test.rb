require "test_helper"
require "hub_kernel/hubs"

module HubKernel
  class HubsTest < ActiveSupport::TestCase
    module Operations
      extend HubKernel::Ports

      port :resource_namer, as: :resource_names
    end

    setup do
      @listed = HubKernel::Hubs.list.dup
      HubKernel::Hubs.list.select! { |hub| hub == Operations }
    end

    teardown do
      HubKernel::Hubs.list.replace(@listed)
      Operations.resource_namer = nil
    end

    test "an app lists every hub that declared a port" do
      assert_includes HubKernel::Hubs.list, Operations
    end

    test "an app with an unfilled port refuses to start and names the port with its hub" do
      assert_raises(HubKernel::UnwiredPortError, match: "Operations' resource namer is not wired") do
        HubKernel::Hubs.check!
      end
    end

    test "an app with every port filled starts" do
      Operations.resource_namer = ->(ids) { ids }

      assert_nothing_raised { HubKernel::Hubs.check! }
    end
  end
end
