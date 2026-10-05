require "active_support/concern"
require "hub_kernel/crossings"

module HubKernel
  module Conformance
    module Crossings
      extend ActiveSupport::Concern

      class_methods do
        def crossings(root: nil, files: "app/**/*.{rb,erb}", except: [], &block)
          define_method(:the_crossings, &block)
          define_method(:crossing_root) { root || Rails.root }
          define_method(:crossing_files) { files }
          define_method(:crossing_exceptions) { except }
        end
      end

      included do
        test "no file names a class another hub owns" do
          flunk "The crossing check found no files to read" if crossing_paths.none? { |path| the_crossings.belongs?(path) }

          found = crossing_paths.flat_map do |path|
            the_crossings.in(path, File.read(File.join(crossing_root, path))).map { |name| "#{path} names #{name}" }
          end
          assert found.empty?, found.join("\n")
        end

        test "every class it reads belongs to a hub" do
          unowned = the_crossings.unowned_classes(crossing_paths)
          assert unowned.empty?, unowned.map { |name| "No hub owns #{name}" }.join("\n")
        end

        test "no class belongs to two hubs" do
          twice = the_crossings.claimed_twice
          assert twice.empty?, twice.map { |name| "Two hubs own #{name}" }.join("\n")
        end

        test "every class the map names exists" do
          missing = the_crossings.missing_classes
          assert missing.empty?, missing.map { |name| "The map names #{name}, which does not exist" }.join("\n")
        end
      end

      def crossing_paths = (Dir.glob(crossing_files, base: crossing_root) - crossing_exceptions).sort
    end
  end
end
