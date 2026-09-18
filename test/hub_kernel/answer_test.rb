require "test_helper"
require "hub_kernel/answer"

module HubKernel
  class AnswerTest < ActiveSupport::TestCase
    class Kept
      def ok? = true

      def message = nil
    end

    test "an answer that says it kept the change meets the contract" do
      assert HubKernel::Answer.met_by?(Kept.new)
    end
  end
end
