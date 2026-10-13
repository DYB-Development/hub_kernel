module HubKernel
  class Engine < ::Rails::Engine
    isolate_namespace HubKernel

    initializer "hub_kernel.hub_folders", before: :set_load_path do |app|
      folders = Dir[app.root.join("hubs/*/app/*")]
      app.config.autoload_paths.concat(folders)
      app.config.eager_load_paths.concat(folders)
    end
  end
end
