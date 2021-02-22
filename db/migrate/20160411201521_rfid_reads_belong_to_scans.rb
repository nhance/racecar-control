class RfidReadsBelongToScans < ActiveRecord::Migration
  def change
    add_column :rfid_reads, :scan_id, :integer, index: true
  end
end
