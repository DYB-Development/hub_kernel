require "test_helper"
require "hub_kernel/conformance/unlinked_ids"

module HubKernel
  module Conformance
    class UnlinkedIdsCheckTest < ActiveSupport::TestCase
      setup do
        connection = ActiveRecord::Base.connection
        connection.create_table(Kitchen::Dish.table_name, force: true) { |table| table.references :recipe; table.references :oven; table.references :chef }
        connection.create_table(Cookbook::Recipe.table_name, force: true) { |table| table.string :name }
        [ Kitchen::Dish, Cookbook::Recipe ].each(&:reset_column_information)
      end

      teardown do
        connection = ActiveRecord::Base.connection
        connection.drop_table(Kitchen::Dish.table_name, if_exists: true)
        connection.drop_table(Cookbook::Recipe.table_name, if_exists: true)
        [ Kitchen::Dish, Cookbook::Recipe ].each(&:reset_column_information)
      end

      test "the unlinked id check fails naming each model and id column no association uses" do
        assert_equal "Kitchen::Dish#chef_id has no association using it\nKitchen::Dish#oven_id has no association using it", unlinked_ids_failure
      end

      test "the unlinked id check leaves out each column the host excepts" do
        assert_equal "Kitchen::Dish#oven_id has no association using it", unlinked_ids_failure(except: [ "Kitchen::Dish#chef_id" ])
      end

      test "the unlinked id check fails when it finds no model with a table in any hub folder" do
        [ Kitchen::Dish, Cookbook::Recipe ].each { |model| ActiveRecord::Base.connection.drop_table(model.table_name) }

        assert_equal "The unlinked id check found no model with a table in any hub folder", unlinked_ids_failure
      end

      private

      def unlinked_ids_failure(**options) = unlinked_ids_run(**options).failures.first&.message

      def unlinked_ids_run(**options)
        check = Class.new(ActiveSupport::TestCase) { include HubKernel::Conformance::UnlinkedIds }
        Minitest::Runnable.runnables.delete(check)
        check.unlinked_ids(**options) if options.any?
        check.new("test_every_id_column_of_a_hub_model_has_an_association").run
      end
    end
  end
end
