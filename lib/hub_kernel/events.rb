module HubKernel
  class UndeclaredEventError < StandardError; end

  module Events
    def declared_events
      instance_methods(false)
    end

    def on(name, &handler)
      raise UndeclaredEventError unless declared_events.include?(name)

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
