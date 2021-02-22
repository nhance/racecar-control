class DriverRegistration2015 < ActiveRecord::Migration
  def change
    create_table :driver_registrations do |t|
      t.belongs_to :driver
      t.belongs_to :registration
      t.string :state, default: "new"
    end
  end
end
