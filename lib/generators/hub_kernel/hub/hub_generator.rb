require "rails/generators/named_base"

module HubKernel
  module Generators
    class HubGenerator < Rails::Generators::NamedBase
      argument :ports, type: :array, default: [], banner: "port:method port:method"

      def create_hub
        create_file "app/models/#{file_path}.rb", <<~RUBY
          module #{class_name}
            extend HubKernel::Ports
          #{port_lines}end
        RUBY
      end

      def create_hub_test
        create_file "test/models/#{file_path}_test.rb", <<~RUBY
          require "test_helper"
          require "hub_kernel/conformance/hub"

          class #{class_name}Test < ActiveSupport::TestCase
            include HubKernel::Conformance::Hub

            hub { #{class_name} }
          end
        RUBY
      end

      def depend_on_hub_kernel
        return unless gemspec

        inject_into_file gemspec, "  spec.add_dependency \"hub_kernel\", \"~> #{HubKernel::VERSION[/\A\d+\.\d+/]}\"\n", before: /^end\s*\z/
      end

      private

      def gemspec = Dir.glob("*.gemspec", base: destination_root).first

      def port_lines
        return "" if ports.empty?

        "\n" + ports.map { |pair| pair.split(":") }.map { |port, method| "  port :#{port}, as: :#{method}\n" }.join
      end
    end
  end
end
