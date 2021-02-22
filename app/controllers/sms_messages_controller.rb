class SmsMessagesController < ApplicationController
  def new
    # Sms Messages can be sent to:
    #  - Everyone
    #  - Specific Driver (autocomplete. Uncheck a box if you want to search entire db)
    #  - All drivers attached to a registration (Specify car #)
    #
    @messages    = SmsMessage.order("(sent_at IS NULL) DESC, sent_at DESC").first(100)
    @drivers     = ContactSerializer.serialize(Driver.where("cell_phone IS NOT NULL").order("last_name ASC, first_name ASC").all)
    @event       = Event.current || Event.next
    @sms_message = SmsMessage.new

    if @event
      @registered_drivers = ContactSerializer.serialize(@event.driver_registrations)
      @registrations = ContactSerializer.serialize(@event.registrations)
      @events = { id: @event.id, name: "All Registered Drivers at #{@event.to_s}" }
    end
  end

  def destroy
    SmsMessage.pending.find(params[:id]).destroy
    flash[:success] = "Message erased from queue"

    redirect_to new_sms_message_path
  end

  def clear_pending
    SmsMessage.pending.destroy_all
    flash[:success] = "Pending messages cleared"

    redirect_to new_sms_message_path
  end

  def resend
    if SmsMessage.find(params[:id]).resend
      flash[:success] = "Message will be sent"
    else
      flash[:error] = "Sending error"
    end
    redirect_to new_sms_message_path
  end

  def create
    messenger = SmsMessenger.new(sms_message_params)
    if messenger.send
      flash[:success] = "#{messenger.send_count} message(s) will be delivered"
    else
      flash[:error] = "Error: #{messenger.error_message}"
    end

    redirect_to new_sms_message_path
  end

  private
  def sms_message_params
    params.require(:sms_message).permit(:resource_type, :resource_id, :message)
  end
end
