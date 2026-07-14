module HubKernel
  class Configuration
    def initialize(registry)
      @registry = registry
    end

    def bind(port, adapter)
      @registry.bind(port, adapter)
    end
  end
end
