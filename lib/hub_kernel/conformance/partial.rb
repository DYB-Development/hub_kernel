require "active_support/concern"

module HubKernel
  module Conformance
    module Partial
      extend ActiveSupport::Concern

      class_methods do
        def markup(&block)
          define_method(:the_markup) { block.call }
        end

        def submits(*names)
          define_method(:the_action_names) { names }
        end
      end

      included do
        def the_action_names = []

        def the_addresses
          return { submit_url: "/an/address" } if the_action_names.empty?

          { submit_urls: the_action_names.to_h { |name| [ name, "/an/address/#{name}" ] } }
        end

        def render_the_markup
          render partial: the_markup, locals: { person: a_person, account: an_account, **the_addresses }
        end

        test "it submits to the addresses it was given" do
          render_the_markup

          expected = the_action_names.empty? ? [ "/an/address" ] : the_action_names.map { |name| "/an/address/#{name}" }
          expected.each { |address| assert_includes rendered, %(action="#{address}") }
        end

        test "it reads nothing from an instance variable" do
          source = File.read(lookup_context.find(the_markup, [], true).identifier)

          assert_no_match(/@[a-z_]+/, source)
        end

        test "it draws no page heading, page frame or layout of its own" do
          render_the_markup

          assert_no_match(/<h1|<html|<body/, rendered)
        end
      end
    end
  end
end
