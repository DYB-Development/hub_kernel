require "test_helper"
require "hub_kernel/conformance/action"

module HubKernel
  module Conformance
    class ActionConformanceTest < ActiveSupport::TestCase
      include HubKernel::Conformance::Action

      saving_object { PretendGem::ChangeName }

      def a_person = "a-person"

      def an_account = "an-account"

      def values_it_keeps = { name: "Pretend Name" }

      def values_it_refuses = { name: "" }
    end
  end
end
