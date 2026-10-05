require "active_support/core_ext/string/inflections"

module HubKernel
  class Crossings
    def initialize(owners:, shared: [], host_layer: nil, interfaces: {})
      @owners = owners
      @shared = shared
      @host_layer = host_layer
      @interfaces = interfaces
    end

    def in(path, source)
      hub = owner_of_file(path)
      source.scan(/[A-Z]\w*(?:::[A-Z]\w*)*/).filter_map { |name| owned_class_in(name) }.uniq.select { |name| crossing?(name, hub) }
    end

    def belongs?(path) = !owner_of_file(path).nil?

    def unowned_classes(paths)
      paths.select { |path| path.end_with?(".rb") && !path.start_with?("app/views/") }.map { |path| class_of(path) }.reject { |name| owner_of(name) }
    end

    private

    def class_of(path) = path.sub(%r{\Aapp/[^/]+/}, "").delete_suffix(".rb").camelize

    def crossing?(name, hub)
      return false if @shared.include?(name) || owner_of(name) == hub

      !(hub == @host_layer && @interfaces.value?(name))
    end

    def owned_class_in(name)
      parts = name.split("::")
      parts.size.downto(1).map { |size| parts.first(size).join("::") }.find { |candidate| owner_of(candidate) }
    end

    def owner_of(class_name) = @interfaces.key(class_name) || @owners.find { |_hub, classes| classes.include?(class_name) }&.first

    def owner_of_file(path)
      return owner_of_view_folder(File.dirname(path.delete_prefix("app/views/")).camelize) if path.start_with?("app/views/")

      owner_of(class_of(path))
    end

    def owner_of_view_folder(folder) = owner_of("#{folder}Controller") || owner_of(folder) || @host_layer
  end
end
