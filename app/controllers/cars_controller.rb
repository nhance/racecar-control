class CarsController < ApplicationController
  before_filter :fetch_team

  def new
    @car = Car.new
  end

  def create
    @car = Car.new(car_params)
    @car.captain = current_driver
    @car.team = @team
    if @car.save
      flash[:notice] = "Your car was successfully added to your team."
      redirect_to team_path
    else
      render action: 'new'
    end
  end

  def index
    @registrations = Event.current.registrations.sort { |a,b| a.car_number.to_i <=> b.car_number.to_i }
  end

  def edit
    @car = @team.cars.find(params[:id])
  end

  def update
    @car = @team.cars.find(params[:id])

    if @car.update_attributes(car_params)
      flash[:success] = "Your car was modified"
      redirect_to team_path
    else
      render action: 'edit'
    end
  end

  def show
    @car = @team.cars.find(params[:id])
    @events = Event.registerable.all

    @registrations = @car.registrations.where(event_id: @events.map(&:id)).all
  end

  def destroy
    @car = @team.cars.find(params[:id])
    if @car.registrations.count == 0
      @car.destroy
      flash[:success] = "Car deleted. You monster, you."
    end
    redirect_to team_path # Silent failure, let them contact us if this isn't working
  end

  private
  def fetch_team
    @team = current_driver.team
    if @team.nil?
      flash[:error] = "You'll need to join or create a team before you can continue."
      redirect_to teams_path
    end
  end

  def car_params
    params.require(:car).permit(:number, :color, :year, :make, :model, :transponder_number)
  end
end
