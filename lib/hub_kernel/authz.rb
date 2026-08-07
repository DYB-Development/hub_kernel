module HubKernel
  module Authz
    def allowed?(actor, action)
      authz.allowed?(actor, action)
    end
  end
end
