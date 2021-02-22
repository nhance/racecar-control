class DriversController < ApplicationController

  def index
    if current_user.present?
      @drivers = Driver.order("created_at DESC").page(params[:page]).per(20)
    elsif current_driver.blank?
      redirect_to new_driver_session_path
      return
    end

    respond_to do |format|
      format.html
      format.csv { send_data Driver.as_csv(params) }
    end
  end

  def barcode
    @driver = Driver.find(params[:id])
    @driver.generate_barcode unless @driver.barcode_exists?

    render layout: false
  end

  def autocomplete
    @drivers = Driver.autocomplete(params[:term])

    respond_to do |format|
      format.json { render json: @drivers.map(&:autocomplete_json) }
    end
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
