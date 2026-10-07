require "test_helper"
require "hub_kernel/hubs"

module HubKernel
  class HubsTest < ActiveSupport::TestCase
    module Operations
      extend HubKernel::Ports

      port :resource_namer, as: :resource_names
      port :usage_reader, as: :resource_usages
    end

    setup do
      @registered, @exposing = HubKernel::Hubs.registered.dup, HubKernel::Interface::ExposingHubs.list.dup
      HubKernel::Hubs.registered.select! { |hub| hub == Operations }
      HubKernel::Interface::ExposingHubs.list.clear
    end

    teardown do
      HubKernel::Hubs.registered.replace(@registered)
      HubKernel::Interface::ExposingHubs.list.replace(@exposing)
      Operations.resource_namer = nil
      Operations.usage_reader = nil
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
      Operations.usage_reader = ->(ids) { ids }

      assert_nothing_raised { HubKernel::Hubs.check! }
    end

    test "a hub declared again on a code reload is on the list once" do
      2.times { declare_catalog }

      assert_equal 1, HubKernel::Hubs.list.count { |hub| hub.name == "HubKernel::HubsTest::Catalog" }
    ensure
      HubsTest.send(:remove_const, :Catalog)
    end

    test "a hub that declares ports and exposes methods is on the list once" do
      hub = Module.new { extend HubKernel::Ports; extend HubKernel::Exposes }
      hub.define_singleton_method(:name) { "Warehouse" }
      hub.port :stock_reader, as: :stock_levels
      hub.exposes :count, takes: [], writes: false

      assert_equal 1, HubKernel::Hubs.list.count { |listed| listed.name == "Warehouse" }
    end

    test "the refusal names every unfilled port" do
      error = assert_raises(HubKernel::UnwiredPortError) { HubKernel::Hubs.check! }

      assert_equal "Operations' resource namer is not wired\nOperations' usage reader is not wired", error.message
    end

    private

    def declare_catalog
      HubsTest.send(:remove_const, :Catalog) if HubsTest.const_defined?(:Catalog, false)
      HubsTest.const_set(:Catalog, Module.new).then do |catalog|
        catalog.extend(HubKernel::Ports)
        catalog.port(:unit_coster, as: :consumable_unit_cost)
      end
    end
  end
end
