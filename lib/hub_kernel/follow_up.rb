module HubKernel
  module FollowUp
    attr_reader :controller

    def initialize(controller:)
      @controller = controller
    end
  end
end
