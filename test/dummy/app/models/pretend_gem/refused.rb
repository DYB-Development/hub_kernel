module PretendGem
  class Refused
    attr_reader :message

    def initialize(message)
      @message = message
    end

    def ok? = false
  end
end
