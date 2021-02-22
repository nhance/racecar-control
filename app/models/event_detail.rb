class EventDetail
  attr_accessor :event, :driver

  def initialize(driver:, event:)
    @event = event
    @driver = driver
  end

  def registered_cars
    if event.present? and driver.present?
      registration_ids = self.event.registrations.pluck(:id)

      driver_registrations = DriverRegistration.where(registration: registration_ids, driver: self.driver)

      driver_registrations.map { |dr| dr.registration.car }
    else
      {}
    end
  end
end
