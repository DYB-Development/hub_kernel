module HubKernel
  module Records
    def saved(record)
      record.save
      record.id
    end

    def removed(record)
      record.destroy
      record.id
    end
  end
end
