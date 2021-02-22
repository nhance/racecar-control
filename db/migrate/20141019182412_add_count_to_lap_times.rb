class AddCountToLapTimes < ActiveRecord::Migration
  def change
    add_column :lap_times, :count, :integer
  end
end
