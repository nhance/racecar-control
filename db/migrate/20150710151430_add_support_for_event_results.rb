class AddSupportForEventResults < ActiveRecord::Migration
  def change
    create_table :races do |t|
      t.references :event, index: true
      t.string   :name
      t.datetime :start_time
      t.datetime :end_time
      t.boolean  :qualifying, default: false
    end
    add_foreign_key :races, :events

    create_table :results do |t|
      t.references :race, index: true
      t.references :registration, index: true

      t.string  :car_class
      t.integer :position
      t.integer :laps
      t.integer :points
      t.datetime :last_lap_at
    end
    add_foreign_key :results, :races
    add_foreign_key :results, :registrations

    add_index :lap_times, :created_at
  end
end
