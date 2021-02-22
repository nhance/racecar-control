class AddAssignToTeamToViolations < ActiveRecord::Migration
  def change
    add_column :violations, :team_id, :integer
  end
end
