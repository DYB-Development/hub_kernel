require "test_helper"
require "hub_kernel/registry"
require "hub_kernel/configuration"

module HubKernel
  class ConfigurationTest < ActiveSupport::TestCase
    test "bind registers the adapter on the registry" do
      adapter = Object.new
      registry = Registry.new
      Configuration.new(registry).bind(:context, adapter)

      assert_same adapter, registry.resolve(:context)
    end
  end
end
