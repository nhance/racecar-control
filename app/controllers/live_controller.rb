class LiveController < ApplicationController
  def ssl_required?
    false
  end

  def show
    @title = "[LIVE] AER"
    @race = Race.find(params[:race_id]) if current_user.present? && params[:race_id].present?
    @race ||= Race.current

    if @race.nil?
      render :no_event
    else
      @event = @race.event
      @registrations = @event.registrations.ready.order_by_car_number
    end
  end
end
