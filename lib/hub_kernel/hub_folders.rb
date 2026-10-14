module HubKernel
  module HubFolders
    ROOT = "hubs".freeze
    CODE = "app".freeze

    PATH = %r{\A#{ROOT}/([^/]+)/}
    CODE_PATH = %r{\A#{ROOT}/[^/]+/#{CODE}/[^/]+/}

    def self.folder(hub) = "#{ROOT}/#{hub}"

    def self.test_folder(hub) = "test/#{folder(hub)}"

    def self.code_glob = "#{ROOT}/*/#{CODE}"

    def self.hub_of(path) = path[PATH, 1]&.to_sym

    def self.class_of(path) = path.sub(CODE_PATH, "").delete_suffix(".rb").camelize

    def self.code_paths(root) = Dir[root.join("#{code_glob}/*")]

    def self.view_paths(root) = Dir[root.join("#{code_glob}/views")]

    def self.helper_paths(root) = Dir[root.join("#{code_glob}/helpers")]

    def self.hub_of_controller(root, page)
      controller = Dir[root.join(code_glob, "controllers", "#{page}_controller.rb").to_s].first
      hub_of(Pathname(controller).relative_path_from(root).to_s)
    end
  end
end
