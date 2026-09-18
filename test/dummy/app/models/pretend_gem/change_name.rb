module PretendGem
  class ChangeName
    include HubKernel::Action

    def call
      return Refused.new("A name is needed") if values[:name].to_s.strip.empty?

      Names.keep(person, values[:name])
      Kept.new
    end
  end
end
