module CurrentDriver
  def self.driving_car(car_number)
    if Event.current
      registration = Event.current.registrations.where(car_number: car_number).first

      if registration
        registration.last_pit_out.try(:driver)
      else
        nil
      end
    else
      puts "Event.current is undefined. No registration data"
      nil
    end
  end
end
