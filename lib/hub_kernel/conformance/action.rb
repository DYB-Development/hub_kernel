require "active_support/concern"

module HubKernel
  module Conformance
    module Action
      extend ActiveSupport::Concern

      class_methods do
        def saving_object(&block)
          saving_objects(the_only: block)
        end

        def saving_objects(**objects)
          define_method(:the_saving_objects) { objects.transform_values(&:call) }
          define_method(:the_saving_object) { the_saving_objects.values.first }
        end
      end

      included do
        test "each named object takes the person, the account and the submitted values" do
          the_saving_objects.each_value do |object|
            assert_respond_to object.new(person: a_person, account: an_account, values: values_it_keeps), :call
          end
        end

        test "each named object answers whether the change was kept" do
          the_saving_objects.each_value do |object|
            answer = object.new(person: a_person, account: an_account, values: values_it_keeps).call

            assert HubKernel::Answer.met_by?(answer), "#{object} must answer with ok? and message"
          end
        end

        test "a refused answer carries the reason" do
          answer = the_saving_object.new(person: a_person, account: an_account, values: values_it_refuses).call

          assert_not_empty answer.message.to_s, "#{the_saving_object} must say why it refused"
        end
      end
    end
  end
end
