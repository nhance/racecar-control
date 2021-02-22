class CreateRfidTests < ActiveRecord::Migration
  def change
    create_table :rfid_tests do |t|
      t.text :params
    end
  end
end
