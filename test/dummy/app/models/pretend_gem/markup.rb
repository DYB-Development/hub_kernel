module PretendGem
  module Markup
    extend HubKernel::Markup

    def self.root = Rails.root.join("app")

    def self.paths_for_the_stylesheet_build
      PretendStylesheetBuild.paths
    end
  end
end
