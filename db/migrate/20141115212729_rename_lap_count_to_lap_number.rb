class RenameLapCountToLapNumber < ActiveRecord::Migration
  def change
    rename_column :lap_times, :count, :lap_number
  end
end
