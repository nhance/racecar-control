class AddExpectedToReadToRfidTests < ActiveRecord::Migration
  def change
    add_column :rfid_tests, :expected_to_read, :text
  end
end
