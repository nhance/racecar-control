class CreateReservableItems < ActiveRecord::Migration
  def change
    create_table :reservable_items do |t|
      t.belongs_to :event
      t.string :name
      t.attachment :image
      t.integer :items_available
      t.integer :uses_per_item, default: 1
    end
  end
end
