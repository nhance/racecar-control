# create_table :cars, force: :cascade do |t|
#   t.string   :barcode,              limit: 255
#   t.datetime :created_at
#   t.datetime :updated_at
#   t.string   :make,                 limit: 255
#   t.string   :model,                limit: 255
#   t.integer  :captain_id,           limit: 4
#   t.string   :passcode,             limit: 255
#   t.integer  :year,                 limit: 4
#   t.integer  :team_id,              limit: 4
#   t.string   :color,                limit: 25
#   t.string   :transponder_number,   limit: 25
#   t.integer  :season_id,            limit: 4
#   t.string   :number,               limit: 5
#   t.integer  :tech_inspection_year, limit: 4
# end
#
# add_index :cars, [:barcode], name: :index_cars_on_barcode, using: :btree

class Car < ActiveRecord::Base
  include BarcodeCapable

  def self.barcode_offset
    20000_00000_00000_00000_000 # 23 digits (24 total with 'C' prepended)
  end

  has_paper_trail

  belongs_to :captain, class_name: 'Driver'
  belongs_to :team
  belongs_to :season

  has_many :registrations, dependent: :destroy

  has_many :scans,   through: :registrations
  has_many :events,  through: :registrations

  has_many :violations, through: :scans

  delegate :drivers, to: :team

  scope :current, -> { where(season_id: Season.current.id) }

  validates :number, :year, :make, :model, :team, presence: true

  validates_uniqueness_of :number, scope: :season_id, allow_nil: false, message: "for car is already taken for this season. :'-( Choose another car number."

  before_validation :assign_to_current_season, if: ->(car) { car.season.blank? }
  before_save :reset_transponder_rentals, if: ->(car) { car.transponder_number_changed? and car.transponder_number_was.blank? }

  def self.find_by_barcode(barcode)
    where(barcode: barcode).first
  end

  def latest_registration
    self.registrations.order("created_at DESC").first
  end

  def to_s
    "##{self.number} #{car_type}"
  end

  def car_number
    number
  end

  def name
    "#{to_s} (#{self.season_id})"
  end

  def rally_baby?
    team.name =~ /rally baby/i
  end

  def team_name
    team.name
  end

  def car_type
    "#{self.year} #{self.make} #{self.model}"
  end

  def registered_for?(event)
    self.registration_ids.include?(event.id)
  end

  def registration_for(event)
    Registration.unscoped.where(car_id: self.id, event_id: event.id).first
  end

  def assign_to_current_season
    self.season = Season.current
  end

  def reset_transponder_rentals
    Registration.unscoped.where(car_id: self.id).future.not_ready.update_all(transponder_rental: false)
  end

  rails_admin do
    show do
      field :barcode do
        formatted_value do
          bindings[:view].link_to bindings[:object].barcode, "/cars/#{bindings[:object].id}/barcode"
        end
      end

      include_all_fields
    end

    list do
      filters [:number, :team, :season_id]

      field :barcode do
        formatted_value do
          bindings[:view].link_to bindings[:object].barcode, "/cars/#{bindings[:object].id}/barcode"
        end
      end
      field :number
      field :year
      field :make
      field :model
      field :team
      field :captain
      field :transponder_number
      field :season_id, :enum do
        filterable true
        enum { (2015..Date.today.year) }
      end

      exclude_fields :id, :created_at, :updated_at
    end
  end
end
