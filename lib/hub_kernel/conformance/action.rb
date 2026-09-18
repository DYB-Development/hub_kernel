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
      end
    end
  end
end
