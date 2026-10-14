require "test_helper"
require "hub_kernel/records"

module HubKernel
  class RecordsTest < ActiveSupport::TestCase
    class Shelf
      include ActiveModel::Model

      attr_accessor :id, :name, :aisle

      validates :name, :aisle, presence: true

      def save = valid?

      def destroy = valid?
    end

    module Shop
      extend HubKernel::Records

      def self.stock(shelf) = saved(shelf)

      def self.clear(shelf) = removed(shelf)
    end

    test "saving a record gives back its id" do
      assert_equal 7, Shop.stock(Shelf.new(id: 7, name: "Soap", aisle: 3))
    end

    test "deleting a record gives back its id" do
      assert_equal 7, Shop.clear(Shelf.new(id: 7, name: "Soap", aisle: 3))
    end

    test "a save that fails is refused with the record's errors as one sentence" do
      assert_raises(HubKernel::Refused, match: /\AName can't be blank and Aisle can't be blank\z/) { Shop.stock(Shelf.new(id: 7)) }
    end

    test "a delete that fails is refused with the record's errors as one sentence" do
      assert_raises(HubKernel::Refused, match: /\AName can't be blank and Aisle can't be blank\z/) { Shop.clear(Shelf.new(id: 7)) }
    end

    test "a hub's callers cannot save or delete through it" do
      assert_empty Shop.public_methods & [ :saved, :removed ]
    end
  end
end
