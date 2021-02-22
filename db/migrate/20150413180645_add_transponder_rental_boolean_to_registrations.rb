class AddTransponderRentalBooleanToRegistrations < ActiveRecord::Migration
  def change
    add_column :registrations, :transponder_rental, :boolean, default: false
  end
end
