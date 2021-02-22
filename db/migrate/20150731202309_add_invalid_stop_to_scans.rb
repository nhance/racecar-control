class AddInvalidStopToScans < ActiveRecord::Migration
  def change
    add_column :scans, :short_stop, :boolean, default: false
  end
end
