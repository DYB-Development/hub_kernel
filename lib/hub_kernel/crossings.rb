require "hub_kernel/hub_folders"
require "active_support/core_ext/string/inflections"

module HubKernel
  class Crossings
    HUB_MODULE = /extend HubKernel::(Ports|Exposes)\b/
    def initialize(owners: {}, shared: [], host_layer: nil, interfaces: {}, namespaces: {}, folder_files: [])
      @owners = owners
      @folder_classes = {}
      read_folders(folder_files)
      @shared = shared
      @host_layer = host_layer
      @interfaces = interfaces
      @folder_interfaces = {}
      @namespaces = namespaces
    end

    def in(path, source)
      hub = owner_of_file(path)
      source.scan(/[A-Z]\w*(?:::[A-Z]\w*)*/).filter_map { |name| owned_class_in(name) }.uniq.select { |name| crossing?(name, hub) }
    end

    def read_folders(paths)
      @folder_classes.merge!(paths.to_h { |path| [ HubFolders.class_of(path), HubFolders.hub_of(path) ] })
      self
    end

    def read_hub_modules(sources)
      sources.each do |path, source|
        next unless source.match?(HUB_MODULE) && path.match?(HubFolders::CODE_PATH)

        @folder_interfaces[HubFolders.class_of(path)] = HubFolders.hub_of(path)
      end
      self
    end

    def belongs?(path) = !owner_of_file(path).nil?

    def unowned_classes(paths)
      paths.select { |path| path.end_with?(".rb") && !path.start_with?("app/views/") && !HubFolders.hub_of(path) }.map { |path| class_of(path) }.reject { |name| owner_of(name) }
    end

    def claimed_twice
      listed = @owners.values.flatten
      listed.tally.select { |_name, hubs| hubs > 1 }.keys | @owners.flat_map { |hub, classes| classes.select { |name| @folder_classes.fetch(name, hub) != hub } }
    end

    def listed_in_their_folders = @owners.flat_map { |hub, classes| classes.select { |name| @folder_classes[name] == hub } }

    def folders_without_hub_module = @folder_classes.values.uniq.reject { |hub| @interfaces.key?(hub) || @folder_interfaces.value?(hub) }.map { |hub| HubFolders.folder(hub) }

    def missing_classes = @owners.values.flatten.uniq.reject { |name| @folder_classes.key?(name) || name.safe_constantize }

    private

    def class_of(path) = path.sub(%r{\Aapp/[^/]+/}, "").delete_suffix(".rb").camelize

    def crossing?(name, hub)
      return false if @shared.include?(name) || owner_of(name) == hub

      !(hub == @host_layer && interface?(name))
    end

    def owned_class_in(name)
      parts = name.split("::")
      listed = parts.size.downto(1).map { |size| parts.first(size).join("::") }.find { |candidate| listed_owner_of(candidate) }
      listed || class_under_namespace(name)
    end

    def class_under_namespace(name)
      space = @namespaces.values.flatten.find { |namespace| name.start_with?("#{namespace}::") }
      space && "#{space}::#{name.delete_prefix("#{space}::").split("::").first}"
    end

    def interface?(name) = @interfaces.value?(name) || @folder_interfaces.key?(name)

    def listed_owner_of(class_name) = @interfaces.key(class_name) || @folder_interfaces[class_name] || @folder_classes[class_name] || @owners.find { |_hub, classes| classes.include?(class_name) }&.first

    def owner_of(class_name) = listed_owner_of(class_name) || owner_of_namespace(class_name)

    def owner_of_namespace(class_name) = @namespaces.find { |_hub, spaces| spaces.any? { |space| class_name.start_with?("#{space}::") } }&.first

    def owner_of_file(path)
      return HubFolders.hub_of(path) if HubFolders.hub_of(path)

      return owner_of_view_folder(File.dirname(path.delete_prefix("app/views/")).camelize) if path.start_with?("app/views/")

      owner_of(class_of(path))
    end

    def owner_of_view_folder(folder) = owner_of("#{folder}Controller") || owner_of(folder) || @host_layer
  end
end
