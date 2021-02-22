class AddCapacityLimitsToEvents < ActiveRecord::Migration
  def change
    add_column :events, :capacity, :integer, default: 50
    add_column :events, :supplemental_limit, :integer, default: 50
  end
end
