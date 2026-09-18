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

    test "offering the path needs nothing beyond rails" do
      gemspec = Gem::Specification.load(HubKernel::Engine.root.join("hub_kernel.gemspec").to_s)

      assert_equal [ "rails" ], gemspec.dependencies.map(&:name)
    end

    test "the path is handed to no stylesheet build here" do
      mentions = Dir.glob(HubKernel::Engine.root.join("lib/**/*.rb")).select { |file| File.read(file).include?("KeystoneUi") }

      assert_empty mentions
    end
  end
end
