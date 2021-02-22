# create_table :fcm_tokens, force: :cascade do |t|
#   t.integer  :driver_id,  limit: 4
#   t.string   :token,      limit: 255
#   t.datetime :created_at
#   t.datetime :updated_at
# end

class FcmToken < ActiveRecord::Base
  belongs_to :driver

  validates :token, presence: true
end
