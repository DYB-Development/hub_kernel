module Larder
  extend HubKernel::Exposes

  exposes :count_of, takes: %i[item], writes: false

  def self.count_of(item:) = item.size
end
