class ScansController < ApplicationController
  def show
    @scan = Scan.includes(:lap_times).find(params[:id])
    @scan.do_processing

    facebook_og "description", "Timing data for #{@scan.driver.try(:full_name)} driving #{@scan.team} ##{@scan.car_number}"
    facebook_og "title", "Driver lap analysis"

    if Event.current && Event.current == @scan.event
      @return_path = "/live"
    else
      @return_path = event_stops_path(@scan.event)
    end
  end

  def create
    raise "Not allowed" unless current_user.present?
    time_zone = (Event.current_or_next || Event.last).time_zone
    Time.use_zone(time_zone) do
      scan = Scan.new(scan_params)

      if scan.save
        flash[:success] = "Scan created!"
      else
        flash[:error] = "ERRORS: #{scan.errors.full_messages.join(', ')}"
      end
    end

    redirect_to "/live"
  end

  def new
    @registration = Registration.find(params[:registration_id])
  end

  def update
    scan = Scan.find(params[:id])
    can_update = current_driver.present? and scan.team == current_driver.team
    can_update = true if current_user.present?
    if can_update
      if current_user.present?
        scan.attributes = scan_params
      end

      scan.driver_id = params[:scan][:driver_id] || Driver.unknown.id
      if scan.save
        flash[:success] = "Driver assigned"
      end
    end

    redirect_to scan_path(params[:id])
  end

  def analyze
    @scan = Scan.find(params[:id])
    unless @scan.processed?
      @scan.process!
    else
      @scan.do_processing
      @scan.save!
    end

    redirect_to @scan
  end

  def mock_pit
    @scan = Scan.find(params[:id])
    if pit_notify = @scan.send_pit_notification
      flash[:success] = "Pit notification sent! Detail: #{pit_notify}"
    else
      flash[:error] = "Pit notification did not send!"
    end

    redirect_to @scan
  end

  def violation
    @scan = Scan.find(params[:id])
    if @scan.violations.create(params[:violation].permit!)
      flash[:success] = "Violation added"
    else
      flash[:error] = "Error adding violation."
    end

    redirect_to @scan
  end

  def scan_params
    params.require(:scan).permit!
  end
end
