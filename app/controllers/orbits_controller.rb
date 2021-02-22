class OrbitsController < ApplicationController
  def export
    @event = Event.current_or_next

    respond_to do |format|
      format.html
      format.csv { send_data get_csv }
    end

  end

private
  def get_csv
    registrations = @event.registrations
    headers = %w{ team_name transponder_id car_number captain_name class vehicle }
    CSV.generate(force_quotes: true) do |csv|
      csv << headers
      registrations.each do |registration|
        csv << registration.orbits_export_data
      end
    end
  end
end
