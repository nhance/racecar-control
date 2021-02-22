class AddVerificationToRegistrations < ActiveRecord::Migration
  def change
    add_column :registrations, :verified, :boolean, default: false
  end
end
