class AddReadAtAndDriverIdToSmsMessages < ActiveRecord::Migration
  def change
    add_column :sms_messages, :driver_id, :integer
    add_column :sms_messages, :read_at, :timestamp

    add_index :sms_messages, [:driver_id, :read_at]
  end
end
