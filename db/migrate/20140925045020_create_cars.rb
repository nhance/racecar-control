class CreateCars < ActiveRecord::Migration
  def change
    create_table :cars do |t|
      t.string :barcode
      t.string :car_number
      t.string :car_class
      t.string :info
      t.integer :event_id

      t.timestamps
    end
  end
end
