require "test_helper"
require "hub_kernel/exposes"
require "open3"

module HubKernel
  class ExposesTest < ActiveSupport::TestCase
    module Supplies
      extend HubKernel::Exposes

      exposes :record_purchase, takes: %i[supplier_id bought_on lines], writes: true
    end

    test "an exposed method is found by its name with the values it takes" do
      assert_equal %i[supplier_id bought_on lines], Supplies.exposed("record_purchase").takes
    end

    test "an app that requires hub_kernel can expose a method with no further require" do
      script = 'require "rails"; require "hub_kernel"; module Supplies; extend HubKernel::Exposes; exposes :record_purchase, takes: [], writes: true; end; print "exposed"'
      output, = Open3.capture2e(RbConfig.ruby, "-I", File.expand_path("../../lib", __dir__), "-e", script)

      assert_equal "exposed", output
    end
  end
end
