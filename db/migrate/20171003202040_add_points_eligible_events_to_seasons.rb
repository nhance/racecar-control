class AddPointsEligibleEventsToSeasons < ActiveRecord::Migration
  def change
    add_column :seasons, :points_eligible_races, :integer, default: nil
  end
end
