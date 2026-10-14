module Kitchen
  class Dish < ApplicationRecord
    belongs_to_port :recipe, port: Kitchen, record: :recipe_record
    has_many_port :recipes, port: Kitchen, record: :recipe_record
  end
end
