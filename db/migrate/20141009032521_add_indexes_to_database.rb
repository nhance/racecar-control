class AddIndexesToDatabase < ActiveRecord::Migration
  def change
    add_index :scans, [:car_number, :driver_id, :team_id]
    add_index :scans, :created_at
    add_index :cars, :barcode
    add_index :drivers, :barcode
    add_index :events, :abbr
  end
end
