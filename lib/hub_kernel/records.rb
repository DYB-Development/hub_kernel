module HubKernel
  module Records
    private

    def saved(record)
      record.save ? record.id : refuse(record, "saved")
    end

    def removed(record)
      record.destroy ? record.id : refuse(record)
    end

    def refuse(record, action = "saved")
      raise Refused, refusal(record, action)
    end

    def refusal(record, action)
      return record.errors.full_messages.to_sentence if record.errors.any?

      "#{record.model_name.human} could not be #{action}"
    end
  end
end
