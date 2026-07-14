module HubKernel
  class UnboundPortError < StandardError; end

  class Registry
    def initialize
      @adapters = {}
    end

    def bind(port, adapter)
      @adapters[port] = adapter
    end

    def resolve(port)
      @adapters.fetch(port) do
        raise UnboundPortError, "no adapter bound for required port :#{port}"
      end
    end
  end
end
