module HubKernel
  module PortAssociations
    def belongs_to_port(name, port:, record:, **options)
      port.link_record(record, [ self.name, name ]) { |model| belongs_to name, **options, class_name: model.name }
    end
  end
end
