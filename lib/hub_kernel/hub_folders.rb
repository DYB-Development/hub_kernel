module HubKernel
  module HubFolders
    def self.code_paths(root) = Dir[root.join("hubs/*/app/*")]

    def self.view_paths(root) = Dir[root.join("hubs/*/app/views")]

    def self.helper_paths(root) = Dir[root.join("hubs/*/app/helpers")]
  end
end
