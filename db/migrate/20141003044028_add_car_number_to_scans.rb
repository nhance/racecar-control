class AddCarNumberToScans < ActiveRecord::Migration
  def change
    add_column :scans, :car_number, :integer
  end
end
