require "hub_kernel/hub_folders"

module HubKernel
  class Engine < ::Rails::Engine
    isolate_namespace HubKernel

    initializer "hub_kernel.hub_folders", before: :set_load_path do |app|
      folders = HubFolders.code_paths(app.root)
      app.config.autoload_paths.concat(folders)
      app.config.eager_load_paths.concat(folders)
    end
  end
end
