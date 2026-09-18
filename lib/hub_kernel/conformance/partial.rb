require "active_support/concern"

module HubKernel
  module Conformance
    module Partial
      extend ActiveSupport::Concern

      class_methods do
        def markup(&block)
          define_method(:the_markup) { block.call }
        end
      end

      included do
        test "it submits to the address it was given" do
          render partial: the_markup, locals: { person: a_person, account: an_account, submit_url: "/an/address" }

          assert_includes rendered, 'action="/an/address"'
        end

        test "it draws no page heading, page frame or layout of its own" do
          render partial: the_markup, locals: { person: a_person, account: an_account, submit_url: "/an/address" }

          assert_no_match(/<h1|<html|<body/, rendered)
        end
      end
    end
  end
end
