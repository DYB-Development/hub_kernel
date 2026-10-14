Rails.application.config.to_prepare do
  Kitchen.recipe_record = Cookbook::Recipe
end
