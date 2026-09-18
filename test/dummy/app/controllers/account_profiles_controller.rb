class AccountProfilesController < ProfilesController
  private

  def submit_url
    account_profile_path
  end
end
