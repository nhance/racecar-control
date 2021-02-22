# create_table :lap_times, force: :cascade do |t|
#   t.integer  :scan_id,      limit: 4
#   t.decimal  :lap_time,                 precision: 8, scale: 3
#   t.boolean  :qualifying,                                       default: false
#   t.string   :track_status, limit: 255
#   t.datetime :created_at
#   t.datetime :updated_at
#   t.integer  :position,     limit: 4
#   t.integer  :lap_number,   limit: 4
#   t.integer  :event_id,     limit: 4
#   t.string   :car_number,   limit: 255
# end
#
# add_index :lap_times, [:created_at], name: :index_lap_times_on_created_at, using: :btree
# add_index :lap_times, [:event_id], name: :index_lap_times_on_event_id, using: :btree

require 'csv'

class LapTime < ActiveRecord::Base
  belongs_to :scan

  has_one :registration, through: :scan
  has_one :result

  delegate :car_number, to: :scan, allow_nil: true
  delegate :driver_name, to: :scan, allow_nil: true

  scope :quali, -> { where(qualifying: true) }
  scope :race,  -> { where(qualifying: false) }

  scope :finish, -> { where(track_status: "Finish") }
  scope :green,  -> { where(track_status: "Green") }

  scope :with_registration, -> { includes(:registration) }

  scope :for_race, ->(race) { where("lap_times.created_at >= ? AND lap_times.created_at <= ?", race.start_time, (race.end_time + 2.hours)) }

  default_scope { order("created_at ASC") }

  before_create do
    self.event_id ||= scan.registration.event_id rescue Event.current
  end

  def self.csv_headers
    %w{ recorded_at car_number driver_name lap_number lap_time position track_status qualifying}
  end

  def finish?
    self.track_status == "Finish"
  end

  def recorded_at
    created_at.strftime("%m/%d %H:%M:%S")
  end

  def fastest?
    scan.present? and scan.processed? and scan.fastest_lap_time == lap_time
  end

  def csv_values
    csv = []

    self.class.csv_headers.each do |column|
      csv << send(column)
    end

    csv
  end

  def name
    self.lap_time
  end

  rails_admin do
    list do
      filters [:created_at, :track_status, :registration]
      scopes [:with_registration]

      field :lap_number
      field :scan
      field :car_number
      field :lap_time
      field :qualifying
      field :position
      field :track_status
      field :created_at

      field :registration do
        queryable true
        search_operator '='
        label "Car number"
        searchable [{Registration => :car_number}]
      end
    end

    show do
      field :lap_number
      field :scan
      field :lap_time
      field :qualifying
      field :position
      field :track_status
      field :created_at
    end
  end
end
