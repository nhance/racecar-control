class TwilioClient
  include Singleton

  def initialize
    if Rails.application.secrets.twilio_numbers.present?
      @twilio_client = Twilio::REST::Client.new(Rails.application.secrets.twilio_account_sid, Rails.application.secrets.twilio_auth_token)
    end
  end

  def client
    if @twilio_client
      @twilio_client
    else
      nil
    end
  end
end

$twilio_client = TwilioClient.instance.client
