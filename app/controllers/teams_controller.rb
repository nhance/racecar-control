class TeamsController < ApplicationController
  before_filter :redirect_to_edit_driver

  def redirect_to_edit_driver
    if not current_driver.valid_with_extra_validation?
      flash[:error] = "We require some additional information before you continue. Please fill in all required fields"
      redirect_to edit_driver_registration_path
    end
  end

  def driver_is_valid?
  end

  def index
    @teams = Team.order("name ASC").all
  end

  def select
    team = Team.find(params[:id])
    if params[:passcode] == team.passcode
      current_driver.team = team
      current_driver.save
      flash[:success] = "You have joined #{team}"
      redirect_to team_path
    else
      flash[:error] = "Incorrect passcode"
      redirect_to teams_path
    end
  end

  def new
    @team = Team.new
  end

  def create
    @team = Team.new(team_params)
    @team.captain = current_driver

    if @team.save
      current_driver.team = @team
      current_driver.save
      flash[:success] = "You've created and joined your team #{@team}!"
      redirect_to team_path
    else
      render action: 'new'
    end
  end

  def show
    @team = current_driver.team
    redirect_to teams_path and return if @team.nil?

    @next_event = Event.next
    @cars       = @team.cars.current
    @drivers    = @team.drivers.order(:last_name)
  end

  def edit
    load_team
  end

  def update
    load_team
    if @team.update_attributes(team_params)
      flash[:success] = "Team changes saved"
      redirect_to team_path
    end
  end

  protected
  def load_team
    @team = current_driver.team
    if @team.captain != current_driver
      flash[:error] = "Sorry, only the team captain can modify the team"
      redirect_to team_path
    end
  end

  def team_params
    params.require(:team).permit(:name, :passcode)
  end

end
