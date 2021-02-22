class AddPriceToReservableItems < ActiveRecord::Migration
  def change
    add_column :reservable_items, :item_price_in_cents, :integer, default: 0
    change_column :reservable_items, :items_available, :text
  end
end
