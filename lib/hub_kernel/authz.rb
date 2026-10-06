module HubKernel
  class NonBooleanAnswerError < StandardError; end
  class NotAllowed < StandardError; end

  module Authz
    singleton_class.attr_accessor :check

    def allowed?(actor, action)
      answer = authz.allowed?(actor, action)
      raise NonBooleanAnswerError, "allowed? must return true or false, got #{answer.inspect}" unless [ true, false ].include?(answer)

      answer
    end
  end
end
