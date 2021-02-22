class AddStopAtToScan < ActiveRecord::Migration
  def change
    add_column :scans, :stop_at, :timestamp
  end
end
