# create_table :sms_messages, force: :cascade do |t|
#   t.string   :number,        limit: 255
#   t.string   :message,       limit: 255
#   t.datetime :sent_at
#   t.integer  :resource_id,   limit: 4
#   t.string   :resource_type, limit: 255
#   t.datetime :created_at
#   t.datetime :updated_at
#   t.integer  :driver_id,     limit: 4
#   t.datetime :read_at
# end
#
# add_index :sms_messages, [:driver_id, :read_at], name: :index_sms_messages_on_driver_id_and_read_at, using: :btree

class SmsMessage < ActiveRecord::Base
  belongs_to :resource, polymorphic: true
  belongs_to :driver

  validates :driver, presence: true

  after_create :send_sms_message

  scope :pending, ->{ where(sent_at: nil) }
  scope :unread,  ->{ where(read_at: nil) }

  def send_sms_message
    if driver.notifications_enabled?
      notification = {
        title: "New Message from AER",
        body: "You have received a new message from AER.",
        sound: 'default'  # Required for sounds
      }

      data = {
        messageTitle: self.created_at.to_s,
        messageBody: self.message,
        messageId: self.id
      }

      $fcm.send([driver.fcm_token],
                notification: notification,
                data: data,
                priority: "high",
                "content_available": true)

      touch(:sent_at)
    elsif self.number.present?
      SmsMessengerJob.perform_async(self.id)
    end
  end

  def resend
    send_sms_message_job
  end

  def title
    (sent_at || created_at).in_time_zone("America/New_York").strftime("%b %e, %Y %l:%M%p")
  end

  def recipient
    if resource.present?
      "#{resource} (#{driver})"
    else
      "#{driver}"
    end
  end
end
