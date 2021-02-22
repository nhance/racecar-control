class ReservationsController < ApplicationController
  def create
    registration = Registration.find(params[:registration_id])
    reservation  = ItemReservation.new(reservable_item_id: params[:reservable_id], registration: registration, item_number: params[:item_number])

    if reservation.save
      flash[:success] = "Successfully reserved #{params[:item_number]}!"

      if registration.paid_in_full?
        redirect_to registration_reservable_path(params[:registration_id], params[:reservable_id])
      else
        flash[:success] << " Please pay your balance"
        redirect_to registration_path(registration)
      end
    else
      flash[:error]   = "Reservation error: #{reservation.errors.full_messages.join("\n")}"
      redirect_to registration_reservable_path(params[:registration_id], params[:reservable_id])
    end
  end

  def destroy
    reservation = ItemReservation.where(registration_id: params[:registration_id],
                                        reservable_item_id: params[:reservable_id]).first

    if reservation.present? and reservation.registration.team == current_driver.team
      reservation.destroy
      flash[:success] = "Registration deleted"
    end

    redirect_to registration_reservable_path(params[:registration_id], params[:reservable_id])
  end
end
