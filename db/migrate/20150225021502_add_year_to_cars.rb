class AddYearToCars < ActiveRecord::Migration
  def change
    add_column :cars, :year, :integer
  end
end
