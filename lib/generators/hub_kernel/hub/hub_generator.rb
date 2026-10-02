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

      private

      def port_lines
        return "" if ports.empty?

        "\n" + ports.map { |pair| pair.split(":") }.map { |port, method| "  port :#{port}, as: :#{method}\n" }.join
      end
    end
  end
end
