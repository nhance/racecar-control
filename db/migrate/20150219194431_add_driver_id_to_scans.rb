class AddDriverIdToScans < ActiveRecord::Migration
  def change
    add_column :scans, :driver_id, :integer
    remove_column :scans, :car_number

    add_column :cars, :captain_id, :integer
    add_column :registrations, :registered_by_id, :integer

    add_column :payments, :created_at, :timestamp
    add_column :payments, :updated_at, :timestamp
  end
end
