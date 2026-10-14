module HubKernel
  module Records
    def saved(record)
      record.save ? record.id : refuse(record)
    end

    def removed(record)
      record.destroy ? record.id : refuse(record)
    end

    def refuse(record)
      raise Refused, record.errors.full_messages.to_sentence
    end
  end
end
