Rails.application.routes.draw do
  mount HubKernel::Engine => "/hub_kernel"

  resource :profile, only: [ :show, :update ]
  resource :account_profile, only: [ :show, :update ], controller: "account_profiles"
end
