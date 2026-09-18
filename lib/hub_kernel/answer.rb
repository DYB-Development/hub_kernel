module HubKernel
  class AnswerNotMetError < StandardError; end

  module Answer
    def self.met_by?(answer)
      answer.respond_to?(:ok?) && answer.respond_to?(:message)
    end

    def self.met!(answer)
      return answer if met_by?(answer)

      raise AnswerNotMetError, "an answer must respond to ok? and message, got #{answer.class}"
    end
  end
end
