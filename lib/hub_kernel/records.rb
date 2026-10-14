module HubKernel
  module Records
    def saved(record)
      record.save ? record.id : raise(Refused, record.errors.full_messages.to_sentence)
    end

    def removed(record)
      record.destroy
      record.id
    end
  end
end
