require "active_support/concern"

module HubKernel
  module Conformance
    module Action
      extend ActiveSupport::Concern

      class_methods do
        def saving_object(&block)
          define_method(:the_saving_object) { block.call }
        end
      end

      included do
        test "it takes the person, the account and the submitted values" do
          object = the_saving_object.new(person: a_person, account: an_account, values: values_it_keeps)

          assert_respond_to object, :call
        end

        test "its answer says whether the change was kept" do
          answer = the_saving_object.new(person: a_person, account: an_account, values: values_it_keeps).call

          assert HubKernel::Answer.met_by?(answer), "#{the_saving_object} must answer with ok? and message"
        end

        test "a refused answer carries the reason" do
          answer = the_saving_object.new(person: a_person, account: an_account, values: values_it_refuses).call

          assert_not_empty answer.message.to_s, "#{the_saving_object} must say why it refused"
        end
      end
    end
  end
end
