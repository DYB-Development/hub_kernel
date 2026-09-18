Rails.application.config.to_prepare do
  PretendStylesheetBuild.paths << PretendGem::Markup.markup_path unless PretendStylesheetBuild.paths.include?(PretendGem::Markup.markup_path)
end
