class SmsMessenger
  include ActionView::Helpers::TextHelper

  def initialize(params)
    # params: { resource_id:, resource_type: 'Class', message: 'to send' }
    # Params feed directly into SMS message, but can create multiple message instances
    # based on the param type

    @send_count = 0
    @error_messages = []
    @params = params
  end

  def send
    @driver_ids = []

    case resource_type
    when 'Driver'
      @driver_ids << resource_id
    when 'DriverRegistration'
      @driver_ids << DriverRegistration.find(resource_id).driver_id
    when 'Registration'
      registration = Registration.find(resource_id)
      registration.driver_registrations.each do |driver_registration|
        @driver_ids << driver_registration.driver_id
      end

    when 'Event'
      event = Event.find(resource_id)
      event.driver_registrations.each do |driver_registration|
        @driver_ids << driver_registration.driver_id
      end
    else
      error "Resource Type is invalid!"
    end

    @driver_ids.uniq!

    deliver_messages

    !has_errors?
  end

  def error_message
    @error_messages.join(', ')
  end

  def has_errors?
    @error_messages.count > 0
  end

  def send_count
    @send_count
  end

  def self.to(resource, message)
    params = { message: message,
               resource_type: resource.class.to_s,
               resource_id: resource.id }

    new(params)
  end

  private
  def error(message)
    @error_messages << message
  end

  def deliver_messages
    Driver.find(@driver_ids).each do |driver|
      sms = SmsMessage.new(@params.clone)
      sms.driver = driver
      sms.number = driver.cell_phone

      if sms.save
        @send_count += 1
      else
        error "SMS(#{sms.driver}): #{sms.errors.full_messages.join(", ")}"
      end
    end
  end

  def resource_id
    @params[:resource_id] || @params['resource_id']
  end

  def resource_type
    @params[:resource_type] || @params['resource_type']
  end
end
