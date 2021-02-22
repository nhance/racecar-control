class AddMathsToScans < ActiveRecord::Migration
  def change
    add_column :scans, :variance, :decimal, precision: 8, scale: 3
    add_column :scans, :std_dev, :decimal, precision: 8, scale: 3
  end
end
