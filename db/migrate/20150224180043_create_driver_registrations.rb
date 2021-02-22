class CreateDriverRegistrations < ActiveRecord::Migration
  def change
    create_table :driver_registrations do |t|
      t.integer :driver_id
      t.integer :registration_id
      t.timestamps
    end

    add_column :cars, :name, :string
    add_column :cars, :passcode, :string
    remove_column :drivers, :captain

  end
end
