require "rails/generators/named_base"

module HubKernel
  module Generators
    class HubGenerator < Rails::Generators::NamedBase
      def create_hub
        create_file "app/models/#{file_path}.rb", <<~RUBY
          module #{class_name}
            extend HubKernel::Ports
          end
        RUBY
      end
    end
  end
end
