require "test_helper"
require "hub_kernel/records"

module HubKernel
  class RecordsTest < ActiveSupport::TestCase
    class Shelf
      include ActiveModel::Model

      attr_accessor :id, :name

      validates :name, presence: true

      def save = valid?

      def destroy = valid?
    end

    module Shop
      extend HubKernel::Records

      def self.stock(shelf) = saved(shelf)

      def self.clear(shelf) = removed(shelf)
    end

    test "saving a record gives back its id" do
      assert_equal 7, Shop.stock(Shelf.new(id: 7, name: "Soap"))
    end

    test "deleting a record gives back its id" do
      assert_equal 7, Shop.clear(Shelf.new(id: 7, name: "Soap"))
    end
  end
end
