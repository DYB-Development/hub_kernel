require "test_helper"
require "hub_kernel/exposes"

module HubKernel
  class ExposesTest < ActiveSupport::TestCase
    module Supplies
      extend HubKernel::Exposes

      exposes :record_purchase, takes: %i[supplier_id bought_on lines], writes: true
    end

    test "an exposed method is found by its name with the values it takes" do
      assert_equal %i[supplier_id bought_on lines], Supplies.exposed("record_purchase").takes
    end
  end
end
