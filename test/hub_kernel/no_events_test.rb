require "test_helper"

module HubKernel
  class NoEventsTest < ActiveSupport::TestCase
    test "hub_kernel offers no events module" do
      assert_raises(LoadError) { require "hub_kernel/events" }
    end
  end
end
