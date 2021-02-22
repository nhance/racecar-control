class AddCarNumberToCars < ActiveRecord::Migration
  def change
    add_column :cars, :number, :string, limit: 5
    Car.reset_column_information

    Registration.all.each do |registration|
      if registration.respond_to?(:car_number)
        registration.car.update_attribute(:number, registration.car_number)
      end
    end
  end
end
