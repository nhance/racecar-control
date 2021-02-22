class CreateItemReservations < ActiveRecord::Migration
  def change
    create_table :item_reservations do |t|
      t.belongs_to :reservable_item
      t.belongs_to :registration
      t.integer :item_number
    end
  end
end
