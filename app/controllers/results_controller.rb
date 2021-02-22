class ResultsController < ApplicationController
  def create
    race = Race.find(params[:race_id])

    # only create results for qualifying
    unless current_user.present? and race.qualifying?
      flash[:notice] = "Only admins can create results for qualifying races"
      redirect_to race.event
    end

    car_classes = race.event.registrations.pluck(:car_class).uniq.compact

    if car_classes.count < 1
      flash[:error] = "You must assign classes first"
      redirect_to event_teams_path(race.event)
      return
    end

    race.generate_results!
    redirect_to grid_race_results_path(race)
  end

  def index
    if params[:race_id]
      race_results
    end

    if params[:event_id]
      event_results
    end

    if params[:season_id]
      redirect_to "https://docs.google.com/spreadsheets/d/1LEYuuy6MJFY3qjd9sq92IYuNSsHQUFbjpd4ufR3-qVg/edit?usp=sharing" and return if params[:season_id].to_i == 2015
      season_results
    end
  end

  def grid
    @race = Race.find(params[:race_id])
    @grid = []

    index = 0
    @race.car_classes.each do |car_class|
      @race.results.sorted.where(car_class: car_class).each do |result|
        @grid << {
          car_number: result.registration.car_number,
          grid: index += 1,
          car_class: car_class,
          team: result.registration.team,
          result: result
        }
      end
    end

    @grid.sort! do |a,b|
      a[:car_number] <=> b[:car_number]
    end

    respond_to do |format|
      format.html { render :grid }
      format.csv { send_data grid_csv }
    end
  end

  def grid_csv
    headers = %w{ car_number team_name class grid_position }
    CSV.generate(force_quotes: true) do |csv|
      csv << headers
      @grid.each do |row|
        csv << ["'#{row[:car_number]}", row[:team].name, row[:car_class], row[:grid]]
      end
    end
  end
  private :grid_csv

  def update_grid
    if current_user.present?
      race = Race.find(params[:race_id])
      if race.qualifying?
        success = true
        params[:results].each_pair do |result_id, result_attr|
          if !Result.where(race_id: params[:race_id]).find(result_id).update_attributes(result_attr.permit(:position))
            success = false
          end
        end

        if success
          flash[:success] = "Grid positions updated"
        else
          flash[:error] = "There was an error saving results. Check positions and try again"
        end
      end
    end

    redirect_to grid_race_results_path(race)
  end

  def preview
    if current_user.present?
      # Gather all of the laptimes that we use to generate results, display them so we have a chance to make changes before race ends
      @race = Race.find(params[:race_id])
      @results = @race.create_results(false)
      @can_generate = @results.count > 0
    end
  end

  def generate
    if current_user.present?
      @race = Race.find(params[:race_id])
      @race.generate_results!
      flash[:success] = "You are now viewing the live results"
      redirect_to race_results_path(@race)
    end
  end

  def update_preview
    if current_user.present?
      # update laptimes that we'll be using to generate results.
      @race = Race.find(params[:race_id])
      success = true
      params[:lap_times].each_pair do |lap_time_id, lap_attr|
        if !LapTime.find(lap_time_id).update_attributes(lap_attr.permit(:lap_number, :created_at))
          success = false
        end
      end

      if success
        flash[:success] = "Lap times updated"
      else
        flash[:error] = "There was an error saving results. Check positions and try again"
      end
    end

    redirect_to preview_race_results_path(@race)
  end

  private
  def race_results
    @race = Race.find(params[:race_id])

    render :race
  end

  def event_results
    @event = Event.friendly.find(params[:event_id])

    render :event
  end

  def season_results
    @season = Season.find(params[:season_id])

    render :season
  end
end
