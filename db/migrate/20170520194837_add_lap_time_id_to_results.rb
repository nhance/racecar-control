class AddLapTimeIdToResults < ActiveRecord::Migration
  def change
    add_column :results, :lap_time_id, :integer
  end
end
