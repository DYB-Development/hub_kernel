require "test_helper"
require "hub_kernel/answer"

module HubKernel
  class AnswerTest < ActiveSupport::TestCase
    class Refused
      def ok? = false

      def message = "That colour is not one of the ones on offer"
    end

    class Kept
      def ok? = true

      def message = nil
    end

    test "an answer that says it kept the change meets the contract" do
      assert HubKernel::Answer.met_by?(Kept.new)
    end

    test "an answer giving neither does not meet the contract" do
      assert_not HubKernel::Answer.met_by?(Object.new)
    end

    test "an object's answer is reported as not meeting the contract when it is asked for" do
      error = assert_raises(HubKernel::AnswerNotMetError) do
        HubKernel::Answer.met!(Object.new)
      end

      assert_match(/ok\?/, error.message)
    end

    test "an answer that was not kept carries the reason" do
      assert_equal "That colour is not one of the ones on offer", HubKernel::Answer.met!(Refused.new).message
    end

    test "an answer that kept the change carries no message" do
      assert_nil HubKernel::Answer.met!(Kept.new).message
    end
  end
end
