class DriverRegistrationsController < ApplicationController
  def index
    @event = Event.friendly.find(params[:event_id])

    respond_to do |format|
      format.html do
        if params[:unapproved]
          @driver_registrations = @event.driver_registrations.page(1).per(1000).reject { |dr| dr.driver&.approved? }
        else
          @driver_registrations = @event.driver_registrations.page(params[:page]).per(50)
        end
      end

      format.csv do
        render csv: @event.driver_registrations, filename: "driver-registrations-#{params[:event_id]}"
      end
    end
  end
end
