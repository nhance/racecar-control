class AddPayments < ActiveRecord::Migration
  def change
    create_table "payments" do |t|
      t.integer :driver_id
      t.integer :registration_id
      t.integer :amount_paid_in_cents
    end

    remove_column :registrations, :driver_id
    remove_column :cars, :car_number
    remove_column :cars, :car_class

    add_column :cars, :make, :string
    add_column :cars, :model, :string

    add_column :registrations, :car_number, :string
    add_column :registrations, :car_class, :string
    add_column :registrations, :price_in_cents, :integer
  end
end
