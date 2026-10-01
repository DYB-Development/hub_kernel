module HubKernel
  module Hubs
    def self.add(hub) = list << hub

    def self.list = @list ||= []
  end
end
