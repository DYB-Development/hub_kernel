require "hub_kernel/version"
require "hub_kernel/engine"
require "hub_kernel/registry"
require "hub_kernel/configuration"

module HubKernel
  def self.registry
    @registry ||= Registry.new
  end

  def self.configure
    yield Configuration.new(registry)
  end

  def self.resolve(port)
    registry.resolve(port)
  end
end
