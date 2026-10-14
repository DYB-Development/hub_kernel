module HubKernel
  module PortAssociations
    def belongs_to_port(name, port:, record:)
      belongs_to name, class_name: port.public_send(record).name
    end
  end
end
