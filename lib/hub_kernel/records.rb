module HubKernel
  module Records
    def saved(record)
      record.save
      record.id
    end
  end
end
