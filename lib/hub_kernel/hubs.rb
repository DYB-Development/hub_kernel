module HubKernel
  module Hubs
    def self.add(hub) = list << hub

    def self.list = @list ||= []

    def self.check!
      unwired = list.flat_map(&:unwired_ports)
      raise UnwiredPortError, unwired.join("\n") if unwired.any?
    end
  end
end
