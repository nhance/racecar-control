class AddSlowestLapToScans < ActiveRecord::Migration
  def change
    add_column :scans, :longest_lap, :decimal, precision: 8, scale: 3
    add_column :scans, :stint_length, :decimal, precision: 8, scale: 3
    add_column :scans, :position_change, :integer
  end
end
