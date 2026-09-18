module PretendGem
  class ForgetTheThemeCookie
    include HubKernel::FollowUp

    def call
      controller.request.cookie_jar.delete(:pretend_gem_theme)
    end
  end
end
