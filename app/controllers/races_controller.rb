class RacesController < ApplicationController
  def index
    @event = Event.friendly.find(params[:event_id])
    @races = @event.races

    # TODO: View doesn't exist yet.
  end
end
