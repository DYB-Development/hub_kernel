require "test_helper"
require "hub_kernel/markup"

module HubKernel
  class MarkupTest < ActiveSupport::TestCase
    class ExampleGem
      extend HubKernel::Markup

      def self.root = Pathname.new("/gems/example")
    end

    test "a gem says where its markup lives in the form a stylesheet build takes" do
      assert_equal "/gems/example/app/views/**/*.erb", ExampleGem.markup_path
    end
  end
end
