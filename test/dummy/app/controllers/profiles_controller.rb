class ProfilesController < ApplicationController
  helper_method :current_person, :current_account, :submit_url

  def show
  end

  def update
    answer = HubKernel::Answer.met!(PretendGem::ChangeName.new(person: current_person, account: current_account, values: { name: params[:name] }).call)
    @refusal = answer.message unless answer.ok?

    render :show
  end

  private

  def submit_url
    profile_path
  end

  def current_person
    "a-person"
  end

  def current_account
    "an-account"
  end
end
