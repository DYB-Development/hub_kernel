require_relative "lib/hub_kernel/version"

Gem::Specification.new do |spec|
  spec.name        = "hub_kernel"
  spec.version     = HubKernel::VERSION
  spec.authors     = [ "tylercschneider" ]
  spec.email       = [ "tylercschneider@gmail.com" ]
  spec.homepage    = "https://github.com/tylercschneider/hub_kernel"
  spec.summary     = "Headless Rails engine that binds a domain to a host app through ports."
  spec.description = "hub_kernel wraps a domain and connects it to a host app's infrastructure through named ports. It ships no domain of its own: each hub is hub_kernel wrapped around one domain."
  spec.license     = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 8.1.3"
end
