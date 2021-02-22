class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.string :name
      t.string :passcode
      t.integer :captain_id
      t.timestamps
    end

    drop_table :driver_registrations
    add_column :cars, :team_id, :integer
    add_column :drivers, :team_id, :integer
    remove_column :cars, :info
  end
end
