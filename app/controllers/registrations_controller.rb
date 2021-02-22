class RegistrationsController < ApplicationController
  def create
    registration = Registration.new(registration_params)
    registration.registered_by = current_driver

    if current_driver.team != registration.car.team
      flash[:error] = "You can't create the registration because you aren't on the team '#{@registration.car.team}'"
      redirect_to :back
    end

    if registration.save
      redirect_to registration_path(registration)
    else
      flash[:error] = registration.errors.full_messages.join(", ")
      redirect_to :back
    end
  end

  def show
    @registration = Registration.unscoped.find(params[:id])
    @payments     = @registration.payments

    if current_driver.team != @registration.car.team
      flash[:error] = "You can't view the registration because you aren't on the team '#{@registration.car.team}'"
      redirect_to '/'
    end

    if @registration.event.sold_out? and !@registration.ready?
      render action: 'full'
    end
  end

  def destroy
    @registration = Registration.unscoped.find(params[:id])

    if current_driver.team != @registration.car.team
      flash[:error] = "You can't delete the registration because you aren't on the team '#{@registration.car.team}'"
      redirect_to '/'
    end

    if @registration.payments.count == 0
      @registration.destroy
      flash[:success] = "Registration deleted. Have fun at that baby shower or whatever."
    end

    redirect_to car_path(@registration.car)
  end

  def update
    @registration = Registration.unscoped.find(params[:id])
    if current_driver.team != @registration.car.team
      flash[:error] = "You can't change registration for a car on another team"
    else
      if @registration.update_attributes(registration_params)
        @registration.process!
        flash[:success] = "Hey, we saved your stuff. Good job."
      else
        flash[:error] = @registration.errors.full_messages.join(",")
      end
    end

    redirect_to registration_path(@registration)
  end

  private
  def registration_params
    params.require(:registration).permit(:car_id, :event_id, :invite_code_code, :car_number, :transponder_rental, :accepts_supplemental_charge)
  end
end
