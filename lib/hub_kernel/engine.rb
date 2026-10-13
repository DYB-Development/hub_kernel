module HubKernel
  class Engine < ::Rails::Engine
    isolate_namespace HubKernel

    initializer "hub_kernel.hub_folders", before: :set_load_path do |app|
      app.config.autoload_paths.concat(Dir[app.root.join("hubs/*/app/*")])
    end
  end
end
