require "active_support/concern"
require "hub_kernel/crossings"

module HubKernel
  module Conformance
    module Crossings
      extend ActiveSupport::Concern

      class_methods do
        def crossings(root: nil, &block)
          define_method(:the_crossings, &block)
          define_method(:crossing_root) { root || Rails.root }
        end
      end

      included do
        test "no file names a class another hub owns" do
          found = Dir.glob("app/**/*.{rb,erb}", base: crossing_root).sort.flat_map do |path|
            the_crossings.in(path, File.read(File.join(crossing_root, path))).map { |name| "#{path} names #{name}" }
          end
          flunk found.join("\n") if found.any?
        end
      end
    end
  end
end
