module HubKernel
  class UndeclaredEventError < StandardError; end
  class UnwiredEventError < StandardError; end

  module Events
    def declared_events
      instance_methods(false)
    end

    def on(name, &handler)
      raise UndeclaredEventError, "undeclared event :#{name}; declared events are #{declared_events}" unless declared_events.include?(name)

      handlers[name] << handler
    end

    def emit(name, payload)
      handlers[name].each { |handler| handler.call(payload) }
    end

    def verify_wired!
      raise UnwiredEventError
    end

    private

    def handlers
      @handlers ||= Hash.new { |table, name| table[name] = [] }
    end
  end
end
