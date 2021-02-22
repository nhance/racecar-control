# create_table :teams, force: :cascade do |t|
#   t.string   :name,       limit: 255
#   t.string   :passcode,   limit: 255
#   t.integer  :captain_id, limit: 4
#   t.datetime :created_at
#   t.datetime :updated_at
# end

class Team < ActiveRecord::Base
  has_many :drivers, dependent: :destroy
  has_many :cars, dependent: :destroy

  has_many :violations

  belongs_to :captain, class_name: 'Driver'

  validates :name, :passcode, presence: true
  validates :name, uniqueness: true

  def to_s
    name
  end

  def rally_baby?
    name =~ /rally baby/i
  end
end
