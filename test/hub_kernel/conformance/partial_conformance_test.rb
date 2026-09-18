require "test_helper"
require "hub_kernel/conformance/partial"

module HubKernel
  module Conformance
    class PartialConformanceTest < ActionView::TestCase
      include HubKernel::Conformance::Partial

      markup { "pretend_gem/name" }

      def a_person = "a-person"

      def an_account = "an-account"
    end
  end
end
