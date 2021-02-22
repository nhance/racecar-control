class CreateLapTimes < ActiveRecord::Migration
  def change
    create_table :lap_times do |t|
      t.integer :scan_id
      t.decimal :lap_time, :precision => 8, :scale => 3
      t.boolean :qualifying, :default => false
      t.string :track_status

      t.timestamps
    end
  end
end
