class ReservablesController < ApplicationController
  before_filter { @event        = event }
  before_filter { @registration = registration }

  def index
    @reservable_items = @event.reservable_items

    if @registration.present?
      @show_item = ->(reservable_item) {
        registration_reservable_path(@registration, reservable_item)
      }
    else
      @show_item = ->(reservable_item) {
        event_reservable_path(@event, reservable_item)
      }
    end
  end

  def show
    @reservable_item = ReservableItem.find(params[:id])
    @reservations = @reservable_item.reservations
  end

  private
  def event
    @event ||=
      if (params[:event_id])
        Event.friendly.find(params[:event_id])
      elsif registration
        registration.event
      end

    @event
  end

  def registration
    @registration ||= Registration.find(params[:registration_id]) if params[:registration_id]
  end
end
