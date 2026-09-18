module PretendGem
  class Names
    def self.store
      @store ||= {}
    end

    def self.for(person)
      store.fetch(person, "Pretend Person")
    end

    def self.keep(person, name)
      store[person] = name
    end

    def self.forget_all
      @store = {}
    end
  end
end
