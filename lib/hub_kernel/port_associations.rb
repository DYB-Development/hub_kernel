module HubKernel
  module PortAssociations
    WRITING_OPTIONS = %i[autosave dependent touch counter_cache].freeze
    LIST_WRITING_METHODS = %i[<< push append concat build new create create! delete destroy delete_all destroy_all clear replace].freeze

    def belongs_to_port(name, scope = nil, port:, record:, **options)
      refuse_writing_options(name, options)
      port.link_record(record, [ self.name, name ]) do |model|
        belongs_to name, read_only(scope), **options, class_name: model.name
        refuse_creating_through(name)
      end
    end

    def has_many_port(name, scope = nil, port:, record:, **options)
      refusal = "#{self.name}'s #{name} link is read-only, so it cannot add, remove, build or create a record"
      port.link_record(record, [ self.name, name ]) do |model|
        has_many name, read_only(scope, refusing_list(refusal)), **options, class_name: model.name
        refuse_replacing_list(name, refusal)
      end
    end

    private

    def refuse_writing_options(name, options)
      writing = options.keys & WRITING_OPTIONS
      raise ArgumentError, "#{name} is a read-only record port link, so it does not take #{writing.to_sentence}" if writing.any?
    end

    def read_only(scope, *extensions)
      return -> { readonly.extending(*extensions) } unless scope
      return -> { instance_exec(&scope).readonly.extending(*extensions) } if scope.arity.zero?

      ->(owner) { instance_exec(owner, &scope).readonly.extending(*extensions) }
    end

    def refusing_list(refusal)
      Module.new { LIST_WRITING_METHODS.each { |method| define_method(method) { |*| raise ActiveRecord::ReadOnlyRecord, refusal } } }
    end

    def refuse_replacing_list(name, refusal)
      [ :"#{name}=", :"#{name.to_s.singularize}_ids=" ].each { |method| define_method(method) { |*| raise ActiveRecord::ReadOnlyRecord, refusal } }
    end

    def refuse_creating_through(name)
      refusal = "#{self.name}'s #{name} link is read-only, so it cannot build or create a record"
      %W[build_#{name} create_#{name} create_#{name}!].each { |method| define_method(method) { |*| raise ActiveRecord::ReadOnlyRecord, refusal } }
      define_method(:"#{name}=") { |linked| linked&.new_record? ? raise(ActiveRecord::ReadOnlyRecord, refusal) : super(linked) }
    end
  end
end
