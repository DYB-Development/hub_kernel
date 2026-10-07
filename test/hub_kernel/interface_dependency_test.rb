require "test_helper"

module HubKernel
  class InterfaceDependencyTest < ActiveSupport::TestCase
    test "hub_kernel takes its exposed-method contract from hub_kernel-interface" do
      assert Gem.loaded_specs.key?("hub_kernel-interface")
    end
  end
end
