class ChangeTypeForItemReservationsItemNumber < ActiveRecord::Migration
  def change
    change_column :item_reservations, :item_number, :string
    add_column :item_reservations, :item_price_in_cents, :integer
  end
end
