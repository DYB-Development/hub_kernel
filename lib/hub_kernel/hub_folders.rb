module HubKernel
  module HubFolders
    def self.code_paths(root) = Dir[root.join("hubs/*/app/*")]
  end
end
