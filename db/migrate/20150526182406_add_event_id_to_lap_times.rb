class AddEventIdToLapTimes < ActiveRecord::Migration
  def change
    add_column :lap_times, :event_id, :integer
    add_index :lap_times, :event_id
  end
end
