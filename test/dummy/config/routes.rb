Rails.application.routes.draw do
  mount HubKernel::Engine => "/hub_kernel"
end
