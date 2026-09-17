module HubKernel
  class MissingArgumentError < ArgumentError; end

  module Action
    attr_reader :person, :account, :values

    def initialize(person:, account:, values:)
      @person = person
      @account = account
      @values = values
    end
  end
end
