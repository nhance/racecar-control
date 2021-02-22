class CreateDrivers < ActiveRecord::Migration
  def change
    create_table :drivers do |t|
      t.string :barcode
      t.string :first_name
      t.string :last_name
      t.string :email
      t.boolean :captain

      t.timestamps
    end
  end
end
