class AddCarNumberToLapTimes < ActiveRecord::Migration
  def change
    add_column :lap_times, :car_number, :string
  end
end
