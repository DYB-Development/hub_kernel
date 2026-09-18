require "test_helper"
require "hub_kernel/follow_up"

module HubKernel
  class FollowUpTest < ActiveSupport::TestCase
    class ExampleFollowUp
      include HubKernel::FollowUp
    end

    test "a follow-up takes the controller it runs in" do
      follow_up = ExampleFollowUp.new(controller: :a_controller)

      assert_equal :a_controller, follow_up.controller
    end
  end
end
