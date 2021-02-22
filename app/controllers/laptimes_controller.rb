class LaptimesController < ApplicationController
  def index
    @event = Event.friendly.find(params[:event_id])

    respond_to do |format|
      format.csv { send_file @event.laptimes_csv_file if @event.laptimes_csv_file_exists? }
      format.html { render text: "Laptimes only available via csv right now" }
    end
  end
end
