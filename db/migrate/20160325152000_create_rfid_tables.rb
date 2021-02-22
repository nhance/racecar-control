class CreateRfidTables < ActiveRecord::Migration
  def change
    create_table :rfid_readers do |t|
      t.string :name
      t.string :mac_address
      t.string :role
      t.string :last_ip_address
      t.timestamps
    end

    create_table :rfid_reads do |t|
      t.belongs_to :rfid_reader
      t.string :reader_role

      t.integer :first_seen_timestamp, limit: 8, index: true
      t.string :antenna_port
      t.string :epc
      t.string :peak_rssi
      t.string :tid
      t.text   :raw_request

      t.timestamps
    end

    add_column :scans, :rfid_read_id, :integer
    add_column :scans, :second_driver_id, :integer
  end
end
