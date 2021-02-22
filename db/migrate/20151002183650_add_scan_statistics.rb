class AddScanStatistics < ActiveRecord::Migration
  def change
    add_column :scans, :processed_at, :datetime
    add_column :scans, :fastest_lap_time, :decimal, precision: 8, scale: 3
    add_column :scans, :average_lap_time, :decimal, precision: 8, scale: 3
    add_column :scans, :total_laps, :integer
    add_column :scans, :state, :string

    Scan.update_all("state = 'unprocessed'")
  end
end
