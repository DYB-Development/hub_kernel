module HubKernel
  module Context
    singleton_class.attr_accessor :scope

    class Null
      def actor
        :null_actor
      end

      def tenant
        :null_tenant
      end
    end
  end
end
