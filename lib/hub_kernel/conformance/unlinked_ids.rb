require "active_support/concern"
require "hub_kernel/hub_folders"

module HubKernel
  module Conformance
    module UnlinkedIds
      extend ActiveSupport::Concern

      class_methods do
        def unlinked_ids(except: [])
          define_method(:unlinked_id_exceptions) { except }
        end
      end

      included do
        test "every id column of a hub model has an association" do
          found = hub_models.flat_map { |model| unlinked_columns(model).map { |column| "#{model.name}##{column}" } } - unlinked_id_exceptions
          found = found.map { |entry| "#{entry} has no association using it" }
          assert found.empty?, found.join("\n")
        end
      end

      def unlinked_id_exceptions = []

      def hub_models
        Dir.glob("#{HubKernel::HubFolders.code_glob}/models/**/*.rb", base: Rails.root).sort
          .map { |path| path.sub(%r{\A.*?/models/}, "").delete_suffix(".rb").camelize.safe_constantize }
          .select { |model| model.is_a?(Class) && model < ActiveRecord::Base && !model.abstract_class? && model.table_exists? }
      end

      def unlinked_columns(model)
        linked = model.reflect_on_all_associations(:belongs_to).map { |association| association.foreign_key.to_s }
        model.column_names.select { |column| column.end_with?("_id") }.sort - linked
      end
    end
  end
end
