class AddReferredByAndEventSupplementalCharges < ActiveRecord::Migration
  def change
    add_column :drivers, :referred_by, :string
    add_column :events, :supplemental_charge, :string
    add_column :registrations, :accepts_supplemental_charge, :boolean, default: false
  end
end
