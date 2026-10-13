require "hub_kernel/hub_folders"

module HubKernel
  class Engine < ::Rails::Engine
    isolate_namespace HubKernel

    initializer "hub_kernel.hub_folders", before: :set_load_path do |app|
      folders = HubFolders.code_paths(app.root)
      app.config.autoload_paths.concat(folders)
      app.config.eager_load_paths.concat(folders)
      app.config.helpers_paths.concat(HubFolders.helper_paths(app.root))
    end

    initializer "hub_kernel.hub_views" do |app|
      views = HubFolders.view_paths(app.root)
      ActiveSupport.on_load(:action_controller) { append_view_path(views) }
    end
  end
end
