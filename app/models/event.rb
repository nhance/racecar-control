# create_table :events, force: :cascade do |t|
#   t.string   :track,               limit: 255
#   t.date     :start_date
#   t.date     :stop_date
#   t.datetime :created_at
#   t.datetime :updated_at
#   t.string   :abbr,                limit: 255
#   t.float    :track_length,        limit: 24
#   t.string   :supplemental_charge, limit: 255
#   t.text     :promo_content,       limit: 65535
#   t.integer  :season_id,           limit: 4
#   t.integer  :capacity,            limit: 4,     default: 50
#   t.integer  :supplemental_limit,  limit: 4,     default: 50
#   t.integer  :price_in_cents,      limit: 4
# end
#
# add_index :events, [:abbr], name: :index_events_on_abbr, using: :btree

class Event < ActiveRecord::Base
  extend FriendlyId

  @@current_event = nil

  has_paper_trail

  friendly_id :abbr

  validates_presence_of :abbr, :track_length
  validates_uniqueness_of :abbr

  belongs_to :season

  has_many :registrations
  has_many :races, -> { order(:start_time) }, dependent: :destroy
  has_many :urls, as: :attached_to

  has_many :cars, through: :registrations
  has_many :payments, through: :registrations
  has_many :scans, through: :registrations
  has_many :driver_registrations, through: :registrations
  has_many :reservable_items

  validates :start_date, :stop_date, presence: true
  validates :season_id, presence: true
  validates :price_in_cents, presence: true

  scope :for_season, ->(season = Season.current) { where(season: season) }
  scope :registerable, -> { where("stop_date >= ?", Date.today) }
  scope :upcoming, ->{ where("start_date > ?", Date.today) }

  default_scope { order(start_date: :asc) }

  before_validation :assign_season_and_price, on: :create

  after_save :create_races!, on: :create

  def self.current
    if @@current_event.nil?
      where("start_date <= ? AND stop_date >= ?", Date.tomorrow, Date.today).first
    elsif @@current_event.is_a?(Event)
      @@current_event
    end
  end

  def self.current_or_next
    self.current || self.next
  end

  def self.next
    upcoming.first
  end

  def sold_out?
    self.registrations.ready.count >= self.capacity
  end

  def time_zone
    "America/New_York"
  end

  def create_races!
    if races.count == 0 and self.start_date.friday?
      friday   = self.start_date.to_time.in_time_zone(self.time_zone)
      saturday = friday   + 1.day
      sunday   = saturday + 1.day

      friday_start = friday.change(hour: 13)
      friday_end   = friday.change(hour: 19, min: 50)

      sat_start = saturday.change(hour: 8,  min: 30) # Allow time for grid scan-in
      sat_end   = saturday.change(hour: 18, min: 30)

      sun_start = sunday.change(hour: 8, min: 30)
      sun_end   = sunday.change(hour: 18, min: 30)

      # Friday Qualifying
      self.races.create(name: "Qualifying", start_time: friday_start, end_time: friday_end, qualifying: true)

      # Saturday
      self.races.create(name: "Saturday Race", start_time: sat_start, end_time: sat_end)

      # Sunday
      self.races.create(name: "Sunday Race", start_time: sun_start, end_time: sun_end)
    end
  end

  def laptimes_csv_file
    Rails.root.join("public/laptimes/#{friendly_id}.csv")
  end

  def laptimes_csv_file_exists?
    File.exists?(laptimes_csv_file)
  end

  def generate_laptimes!
    laptimes = LapTime.where(event_id: id).all
    headers = LapTime.csv_headers

    CSV.open(laptimes_csv_file, 'w') do |csv|
      csv << headers
      laptimes.each do |laptime|
        csv << laptime.csv_values
      end
    end
  end

  def drivers
    teams = cars.map(&:team)
    teams.uniq!

    teams.map(&:drivers).flatten
  end

  def upcoming?
    self.start_date >= Date.today
  end

  def past?
    !upcoming?
  end

  def current?
    self.start_date <= Date.today && self.stop_date >= Date.today
  end

  def name
    self.to_s
  end

  def to_s
    "#{self.track} (#{self.start_date})"
  end

  def allows_supplemental_charge?
    self.supplemental_charge.present? &&
      registrations.where(accepts_supplemental_charge: true).count < supplemental_limit
  end

  def assign_class(car_numbers:, car_class:)
    Registration.transaction do
      car_numbers.each do |car_number|
        registrations.by_car_number(car_number).update_attributes!(car_class: car_class)
      end
    end
  end

  def overall_winners
    results = races.map { |race| race.results.sorted }.flatten

    # {
    #   'Daytona' => [{
    #       total: 42,
    #       results: [#<Result "Saturday">, #<Result "Sunday">],
    #       car_id: 31,
    #       team: #<Team "Rally Baby">
    #       },
    #     ]
    # }

    winners = {}

    results.each do |result|
      if winners[result.car_class].nil?
        winners[result.car_class] = []
      end

      already_a_winner = false # Racing is serious business. Not everyone is a winner.

      winners[result.car_class].each do |winner|
        if winner[:car_id] == result.car.id
          winner[:results] << result
          winner[:total] += result.points_with_adjustments

          already_a_winner = true
        end
      end

      if !already_a_winner
        winner = {
            results: [result],
            registration: result.registration,
            car_id: result.car.id,
            team: result.team,
            total: result.points_with_adjustments
          }

        winners[result.car_class] << winner
      end
    end

    winners
  end

  def pretty_overall_winners
    pretty_winners = {}

    overall_winners.each_pair do |car_class, winners|
      if pretty_winners[car_class].nil?
        pretty_winners[car_class] = []
      end
      winners.each do |winner|
        pretty_winner = {
          total: winner[:total],
          car: "##{winner[:registration].car_number} #{winner[:team]}"
        }

        pretty_winners[car_class] << pretty_winner
      end

      pretty_winners[car_class].sort_by! { |pw| pw[:total] }.reverse!

      # Need to put in code for tie breakers.
      # Teams with a tie are sorted with the best finish on Sunday coming first
    end

    pretty_winners
  end

  def assign_season_and_price
    self.season         ||= Season.current
    self.price_in_cents ||= self.season.event_price_in_cents
  end

  rails_admin do
    configure :drivers do
      visible false

      pretty_value do
        bindings[:object].drivers.map(&:to_s).join(",<br> ").html_safe
      end
    end

    configure :driver_emails do
      formatted_value { "Driver emails" }

      visible false

      pretty_value do
        bindings[:object].drivers.map(&:mailchimp_csv).join("<br> ").html_safe
      end
    end

    list do
      filters [:season_id]

      field :season_id, :enum do
        filterable true

        enum { Season.select(:id).all }
      end

      field :track
      field :abbr
      field :track_length
      field :start_date
      field :stop_date
    end

    show do
      field :season
      field :track
      field :abbr
      field :track_length
      field :start_date
      field :stop_date
      field :drivers
      field :driver_emails
      field :promo_content
    end

    edit do
      field :season
      field :track
      field :abbr
      field :track_length
      field :start_date
      field :stop_date
      field :supplemental_charge
      field :promo_content
      field :capacity
      field :supplemental_limit
      field :urls
      field :price_in_cents
    end
  end
end
