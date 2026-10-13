module HubKernel
  module HubFolders
    def self.code_paths(root) = Dir[root.join("hubs/*/app/*")]

    def self.view_paths(root) = Dir[root.join("hubs/*/app/views")]
  end
end
