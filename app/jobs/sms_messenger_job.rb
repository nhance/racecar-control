class SmsMessengerJob
  include Sidekiq::Worker

  sidekiq_options backtrace: true

  def perform(sms_message_id)
    sms = SmsMessage.find(sms_message_id)

    message_params = { to: "+1#{sms.number}",
                       from: "+1#{Rails.application.secrets.twilio_numbers.sample}",
                       body: "#{sms.message} [MESSAGE SENT FROM AER RACE CONTROL]" }

    Rails.logger.info("(#{sms_message_id})Twilio.account.messages.create: #{message_params.inspect}")

    if $twilio_client && $twilio_client.account.messages.create(message_params)
      sms.sent_at = Time.now
      sms.save!
    end
  end
end
