class AddNotesToDrivers < ActiveRecord::Migration
  def change
    add_column :drivers, :notes, :text
    add_column :drivers, :admin_notes, :text
    remove_column :drivers, :internal_comments
  end
end
