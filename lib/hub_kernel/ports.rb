module HubKernel
  module Ports
    def port(name, as:)
      singleton_class.attr_accessor name
      define_singleton_method(as) { |*args, **options| public_send(name).call(*args, **options) }
    end
  end
end
