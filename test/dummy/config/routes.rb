Rails.application.routes.draw do
  mount HubKernel::Engine => "/hub_kernel"

  resource :profile, only: [ :show, :update ]
end
