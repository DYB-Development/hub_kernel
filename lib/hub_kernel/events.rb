module HubKernel
  module Events
    def declared_events
      instance_methods(false)
    end
  end
end
