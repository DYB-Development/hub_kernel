module HubKernel
  class NonBooleanAnswerError < StandardError; end

  module Authz
    module Vocabulary
      def gates(*actions)
        gated_actions.concat(actions)
      end

      def gated_actions
        @gated_actions ||= []
      end
    end

    def self.included(hub)
      hub.extend(Vocabulary)
    end

    def allowed?(actor, action)
      answer = authz.allowed?(actor, action)
      raise NonBooleanAnswerError, "allowed? must return true or false, got #{answer.inspect}" unless [ true, false ].include?(answer)

      answer
    end
  end
end
