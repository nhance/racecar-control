class AddLapCountAdjustmentToDrivers < ActiveRecord::Migration
  def change
    add_column :drivers, :lap_count_adjustment, :integer, default: 0
  end
end
