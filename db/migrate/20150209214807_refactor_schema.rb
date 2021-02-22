class RefactorSchema < ActiveRecord::Migration
  def change
    remove_column :cars, :event_id
    remove_column :scans, :team_id
    remove_column :scans, :driver_id
    remove_column :scans, :event_id

    create_table "registrations" do |t|
      t.integer :event_id
      t.integer :car_id
      t.integer :driver_id
      t.timestamps
    end

    add_index :registrations, [:event_id, :car_id, :driver_id]

    add_column :scans, :registration_id, :integer
  end
end
