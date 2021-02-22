class EventsController < ApplicationController
  def index
    @seasons = Season.all
    @year = params[:year] || Season.current.year
    @events = Event.for_season(Season[@year])
  end

  def teams
    @event = find_event
    @registrations = @event.registrations.expected_at_event.order_by_car_number
  end

  def stops
    @event = find_event
    @registrations = @event.registrations.expected_at_event.order_by_car_number
  end

  def registrations
    if current_user.present?

      update = []
      params[:registrations].each_pair do |id, attribs|
        Registration.where(id: id).update_all(car_class: attribs["car_class"], verified: attribs["verified"].to_s == 'true')
      end
      flash[:success] = "Car classes assigned"
    end
    redirect_to event_teams_path(find_event)
  end

  private
  def find_event
    Event.friendly.find(params[:event_id])
  end
end
