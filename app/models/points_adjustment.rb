# create_table :points_adjustments, force: :cascade do |t|
#   t.integer  :race_id,         limit: 4
#   t.integer  :registration_id, limit: 4
#   t.integer  :points,          limit: 4
#   t.string   :reason,          limit: 255
#   t.datetime :created_at,                  null: false
#   t.datetime :updated_at,                  null: false
# end

class PointsAdjustment < ActiveRecord::Base
  belongs_to :race
  belongs_to :registration

  validates :reason, presence: true
end
