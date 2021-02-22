# create_table :results, force: :cascade do |t|
#   t.integer  :race_id,         limit: 4
#   t.integer  :registration_id, limit: 4
#   t.string   :car_class,       limit: 255
#   t.integer  :position,        limit: 4
#   t.integer  :laps,            limit: 4
#   t.integer  :points,          limit: 4
#   t.datetime :last_lap_at
#   t.integer  :lap_time_id,     limit: 4
# end
#
# add_index :results, [:race_id], name: :index_results_on_race_id, using: :btree
# add_index :results, [:registration_id], name: :index_results_on_registration_id, using: :btree

class Result < ActiveRecord::Base
  belongs_to :race
  belongs_to :registration
  belongs_to :lap_time#, optional: true

  delegate :car, to: :registration
  delegate :team, to: :car

  # validates_uniqueness_of :position, scope: :race_id, on: :update

  scope :sorted, ->{ order("car_class DESC, position ASC") }

  def points_adjustments
    PointsAdjustment.where(race_id: self.race_id, registration_id: self.registration_id)
  end

  def points_with_adjustments
    self.points.to_i + self.adjustment_points.to_i
  end

  def adjustment_points
    points_adjustments.sum(:points)
  end

  def adjustment_reasons
    points_adjustments.pluck(:reason).join("; ")
  end

  def adjust!(delta, reason:)
    PointsAdjustment.create!(race_id: self.race_id, registration_id: self.registration_id, points: delta.to_i, reason: reason)
  end

  rails_admin do
    list do
      field :race
      field :registration
      field :car_class
      field :position
      field :points
      field :laps
      field :last_lap_at
    end
  end
end
