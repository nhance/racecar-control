class CreateScans < ActiveRecord::Migration
  def change
    create_table :scans do |t|
      t.integer :team_id
      t.integer :driver_id
      t.string :pit
      t.integer :event_id

      t.timestamps
    end
  end
end
