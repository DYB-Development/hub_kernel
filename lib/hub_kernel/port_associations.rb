module HubKernel
  module PortAssociations
    def belongs_to_port(name, port:, record:, **options)
      belongs_to name, **options, class_name: port.public_send(record).name
    end
  end
end
