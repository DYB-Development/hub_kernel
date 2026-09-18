module HubKernel
  class AnswerNotMetError < StandardError; end

  module Answer
    def self.met_by?(answer)
      answer.respond_to?(:ok?) && answer.respond_to?(:message)
    end
  end
end
