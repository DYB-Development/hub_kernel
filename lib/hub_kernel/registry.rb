module HubKernel
  class Registry
    def initialize
      @adapters = {}
    end

    def bind(port, adapter)
      @adapters[port] = adapter
    end

    def resolve(port)
      @adapters.fetch(port)
    end
  end
end
