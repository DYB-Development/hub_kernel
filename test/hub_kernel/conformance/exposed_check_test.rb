require "test_helper"
require "hub_kernel/conformance/exposed"

module HubKernel
  module Conformance
    class ExposedCheckTest < ActiveSupport::TestCase
      module Pantry
        extend HubKernel::Exposes

        exposes :count_jars, takes: %i[shelves], writes: false
      end

      test "the exposed-list check fails and names each problem with the hub's exposed list" do
        assert_equal "Pantry exposes count_jars, which it has no method for", exposed_check_failure(Pantry)
      end

      private

      def exposed_check_failure(hub)
        check = Class.new(ActiveSupport::TestCase) { include HubKernel::Conformance::Exposed }
        Minitest::Runnable.runnables.delete(check)
        check.hub { hub }
        check.runnable_methods.filter_map { |name| check.new(name).run.failures.first&.message }.first
      end
    end
  end
end
