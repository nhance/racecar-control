class UnknownDriversController < ApplicationController
  before_filter :require_admin

  def index
    if params[:race_id] == "current"
      @race = Race.current
    else
      @race = Race.find(params[:race_id])
    end

    @unknown_driver_scans = @race.scans.out.where("registration_id IS NOT NULL").with_unknown_driver.order("stop_at DESC")
  end
end
