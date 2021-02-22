class RfidtestsController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def create
    if RfidTest.create(params: rfid_params)
      head :ok
    else
      head :unprocessable_entity
    end
  end

  def rfid_params
    params.to_unsafe_h.except("controller", "action")
  end
end
