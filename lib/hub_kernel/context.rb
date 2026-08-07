module HubKernel
  module Context
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
