class CarController < ApplicationController
  def ssl_required?
    false
  end

  def sell
    render layout: 'sell'
  end

  def index
    cols = [:car_number, :info, :barcode]
    cars = Car.select(cols).order(:car_number)
    list = ''
    cars.each{ |r| list += r.attributes.except(:id).values.to_csv }
    render plain: list
  end

  def barcode
    @car = Car.find(params[:id])
    @car.generate_barcode unless @car.barcode_exists?

    render layout: false
  end

  def show
    respond_to do |format|
      format.html
      format.pdf do
        render :pdf => "show"
      end
    end
  end
end
