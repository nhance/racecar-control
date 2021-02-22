class AddPriceInCentsToEvents < ActiveRecord::Migration
  def change
    add_column :events, :price_in_cents, :integer
    Event.update_all(price_in_cents: 1800_00)
  end
end
