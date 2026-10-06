module HubKernel
  class NonBooleanAnswerError < StandardError; end
  class NotAllowed < StandardError; end

  module Authz
    singleton_class.attr_accessor :check
  end
end
