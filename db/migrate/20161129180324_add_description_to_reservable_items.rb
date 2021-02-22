class AddDescriptionToReservableItems < ActiveRecord::Migration
  def change
    add_column :reservable_items, :description, :text
  end
end
