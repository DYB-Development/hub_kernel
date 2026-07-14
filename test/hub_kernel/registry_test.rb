require "test_helper"
require "hub_kernel/registry"

module HubKernel
  class RegistryTest < ActiveSupport::TestCase
    test "resolve returns the adapter bound to a port" do
      adapter = Object.new
      registry = Registry.new
      registry.bind(:context, adapter)

      assert_same adapter, registry.resolve(:context)
    end
  end
end
