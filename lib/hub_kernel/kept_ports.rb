require "active_support/concern"

module HubKernel
  module KeptPorts
    extend ActiveSupport::Concern

    class_methods do
      def keep_ports(&block)
        define_method(:hubs_with_kept_ports) { Array(instance_exec(&block)) }
      end
    end

    included do
      setup { @kept_ports = hubs_with_kept_ports.to_h { |hub| [ hub, fillings_of(hub) ] } }
      teardown { @kept_ports.each { |hub, fillings| fillings.each { |port, filling| hub.public_send(:"#{port}=", filling) } } }
    end

    private

    def fillings_of(hub) = hub.port_names.to_h { |port| [ port, hub.instance_variable_get(:"@#{port}") ] }
  end
end
