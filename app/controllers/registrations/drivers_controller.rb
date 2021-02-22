class Registrations::DriversController < ApplicationController
  def index
    @registration = Registration.find(params[:registration_id])
    @event = @registration.event
    @driver_registrations = DriverRegistration.where(registration: @registration)
    @im_driving = @registration.registered_driver?(current_driver)
  end

  def create
    registration = Registration.find(params[:registration_id])
    driver = Driver.find(params[:driver_id])
    render_404 unless registration.present? and driver.present?

    if driver.team == current_driver.team and DriverRegistration.create(driver: driver, registration: registration)
      flash[:success] = "Okay! We'll look for #{driver} at #{registration.event}"
      respond_to do |format|
        format.html do
          redirect_to registration_drivers_path
        end
        format.json { head :ok }
      end
    else
      flash[:error] = "Driver registration error. Is #{driver} on your team?"
      respond_to do |format|
        format.html do
          redirect_to registration_drivers_path
        end
        format.json { head :unprocessable_entity }
      end
    end

  end

  def destroy
    registration = Registration.find(params[:registration_id])
    driver_registration = registration.driver_registrations.find(params[:id])
    driver = driver_registration.driver

    if driver_registration.destroy
      flash[:success] = "#{driver.full_name} removed"
    else
      flash[:error] = "Can't remove driver!"
    end
    redirect_to registration_drivers_path(registration)
  end
end
