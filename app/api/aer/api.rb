require 'doorkeeper/grape/helpers'

module Aer
  class API < Grape::API
    version 'v1', using: :header, vendor: 'aer'

    format :json
    formatter :json, Grape::Formatter::Rabl

    helpers Doorkeeper::Grape::Helpers

    before do
      doorkeeper_authorize! unless Rails.env.development?
    end

    helpers do
      def current_driver
        if doorkeeper_token
          Driver.find(doorkeeper_token.resource_owner_id)
        elsif Rails.env.development?
          Driver.find(3) # Nick Hance

          #Driver.find(827) # John Kolesa
        end
      end
    end

    resource :messages do
      desc "Returns all sms messages for the current driver"
      params do
        optional :scope
      end
      get do
        @messages = current_driver.sms_messages.order("sent_at DESC, created_at DESC").limit(50)

        unless params[:scope] == 'all'
          @messages = @messages.unread
        end

        render rabl: 'messages'
      end

      desc "Update read status"
      params do
        requires :ids, type: Array[Integer]
      end
      post :read do
        current_driver.sms_messages.where(id: params[:ids]).update_all(read_at: Time.now)
      end
    end


    resource :event_details do
      desc 'Get current event details for driver'
      get :current do
        @event_detail = EventDetail.new(driver: current_driver, event: Event.current_or_next)

        render rabl: 'event_detail'
      end
    end

    resource :driver do
      desc "Submit device details (for notification, etc)"
      params do
        requires :fcm_token
      end
      post do
        if current_driver
          current_driver.update_attribute(:fcm_token, params[:fcm_token])
          { result: "FCM token saved" }
        else
          { result: "Driver not found" }
        end
      end
    end
  end
end
