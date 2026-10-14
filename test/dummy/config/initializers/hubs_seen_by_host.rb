HUBS_SEEN_BY_HOST = []

Rails.application.config.to_prepare do
  HUBS_SEEN_BY_HOST.replace(HubKernel::Hubs.list.map(&:name))
end
