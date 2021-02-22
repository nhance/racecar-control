class RemoveCarNameAddTransponder < ActiveRecord::Migration
  def change
    remove_column :cars, :name
    add_column :cars, :color, :string, limit: 25
    add_column :cars, :transponder_number, :string, limit: 25
    add_column :registrations, :transponder_number, :string, limit: 25
  end
end
