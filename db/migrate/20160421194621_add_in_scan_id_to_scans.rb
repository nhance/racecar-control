class AddInScanIdToScans < ActiveRecord::Migration
  def change
    add_column :scans, :in_scan_id, :integer
  end
end
