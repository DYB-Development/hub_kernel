require "active_support/core_ext/string/inflections"

module HubKernel
  class Crossings
    def initialize(owners:)
      @owners = owners
    end

    def in(path, source)
      hub = owner_of_file(path)
      source.scan(/[A-Z]\w*(?:::[A-Z]\w*)*/).uniq.select { |name| owner_of(name) && owner_of(name) != hub }
    end

    private

    def owner_of(class_name) = @owners.find { |_hub, classes| classes.include?(class_name) }&.first

    def owner_of_file(path) = owner_of(path.sub(%r{\Aapp/[^/]+/}, "").delete_suffix(".rb").camelize)
  end
end
