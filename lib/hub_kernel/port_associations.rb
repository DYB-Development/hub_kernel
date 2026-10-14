module HubKernel
  module PortAssociations
    WRITING_OPTIONS = %i[autosave dependent touch counter_cache].freeze

    def belongs_to_port(name, scope = nil, port:, record:, **options)
      refuse_writing_options(name, options)
      port.link_record(record, [ self.name, name ]) do |model|
        belongs_to name, read_only(scope), **options, class_name: model.name
        refuse_creating_through(name)
      end
    end

    private

    def refuse_writing_options(name, options)
      writing = options.keys & WRITING_OPTIONS
      raise ArgumentError, "#{name} is a read-only record port link, so it does not take #{writing.to_sentence}" if writing.any?
    end

    def read_only(scope)
      return -> { readonly } unless scope
      return -> { instance_exec(&scope).readonly } if scope.arity.zero?

      ->(owner) { instance_exec(owner, &scope).readonly }
    end

    def refuse_creating_through(name)
      refusal = "#{self.name}'s #{name} link is read-only, so it cannot build or create a record"
      %W[build_#{name} create_#{name} create_#{name}!].each { |method| define_method(method) { |*| raise ActiveRecord::ReadOnlyRecord, refusal } }
      define_method(:"#{name}=") { |linked| linked&.new_record? ? raise(ActiveRecord::ReadOnlyRecord, refusal) : super(linked) }
    end
  end
end
