module HubKernel
  module Events
    def declared_events
      instance_methods(false)
    end

    def on(name, &handler)
      handlers[name] << handler
    end

    def emit(name, payload)
      handlers[name].each { |handler| handler.call(payload) }
    end

    private

    def handlers
      @handlers ||= Hash.new { |table, name| table[name] = [] }
    end
  end
end
