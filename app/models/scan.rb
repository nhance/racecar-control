# create_table :scans, force: :cascade do |t|
#   t.string   :pit,              limit: 255
#   t.datetime :created_at
#   t.datetime :updated_at
#   t.datetime :stop_at
#   t.integer  :registration_id,  limit: 4
#   t.integer  :driver_id,        limit: 4
#   t.boolean  :short_stop,                                           default: false
#   t.datetime :processed_at
#   t.decimal  :fastest_lap_time,             precision: 8, scale: 3
#   t.decimal  :average_lap_time,             precision: 8, scale: 3
#   t.integer  :total_laps,       limit: 4
#   t.string   :state,            limit: 255
#   t.decimal  :variance,                     precision: 8, scale: 3
#   t.decimal  :std_dev,                      precision: 8, scale: 3
#   t.decimal  :longest_lap,                  precision: 8, scale: 3
#   t.decimal  :stint_length,                 precision: 8, scale: 3
#   t.integer  :position_change,  limit: 4
#   t.integer  :rfid_read_id,     limit: 4
#   t.integer  :second_driver_id, limit: 4
#   t.integer  :in_scan_id,       limit: 4
# end
#
# add_index :scans, [:created_at], name: :index_scans_on_created_at, using: :btree

class Scan < ActiveRecord::Base
  include AASM
  include ScansHelper

  MIN_PIT_TIME = 3 * 60

  has_paper_trail

  attr_accessor :message, :response_code

  has_many :violations, dependent: :nullify
  has_many :lap_times, dependent: :nullify

  belongs_to :registration
  belongs_to :driver

  has_many :rfid_reads

  belongs_to :in_scan, class_name: 'Scan'
  has_one :out_scan, class_name: 'Scan', foreign_key: :in_scan_id

  has_one :car, through: :registration
  has_one :team, through: :car

  delegate :driver_name, to: :driver, allow_nil: true
  delegate :car_number, to: :registration, allow_nil: true
  delegate :event, to: :registration

  validates_presence_of :driver_id, :registration_id, :pit

  after_create :assign_stop_time
  after_create :associate_with_scan_in_job

  PITS = %w{ IN OUT }
  validates :pit, inclusion: { in: PITS }

  validate :validate_barcode_but_save_anyway_yolo

  scope :in, -> { where(pit: "IN") }
  scope :out, -> { where(pit: "OUT") }
  scope :not_short_stop, -> { where(short_stop: false) }
  scope :with_unknown_driver, -> { where(driver_id: Driver.unknown.id) }

  aasm column: :state do
    state :unprocessed, initial: true
    state :processed, before_enter: :do_processing

    event :process do
      transitions from: :unprocessed, to: :processed
    end
  end

  def self.valid
    where(response_code: 'VALID')
  end

  def self.for_current_race
    race = Race.current

    for_race(race)
  end

  def race
    # Finds the race for this scan
    # Matches races that start up to 5 minutes after scan or
    # that end up to 5 minutes before scan
    Race.where("start_time <= ? AND end_time >= ?", self.stop_at + 5.minutes, self.stop_at - 5.minutes).first
  end

  def self.for_race(race)
    return where("'A'='A'") if race.nil?

    where("stop_at >= ? AND stop_at <= ?", race.start_time - 5.minutes, race.end_time + 5.minutes)
  end

  def previous
    if self.registration.present?
      scans = self.registration.scans.order("stop_at")

      if !new_record?
        scans = scans.where(["id != ?", self.id])
      end

      scans.last
    end
  end

  def out?
    pit == 'OUT'
  end

  def in?
    pit == 'IN'
  end

  def processable?
    not processed?
  end

  def has_pit_time?
    self.in_scan.present? and self.in_scan.stop_at < self.stop_at
  end

  def pit_time
    if has_pit_time?
      self.stop_at - self.in_scan.stop_at
    end
  end

  def stop_at
    self[:stop_at] || self[:created_at]
  end

  def do_processing(variance_filter: 0.15)
    first_lap = self.lap_times.first
    last_lap = self.lap_times.last

    # Finds the total number of laps recorded.
    # Since it's possible we could miss the record of some laps, we'll use the data from orbits to tell us the count.
    self.total_laps = self.lap_times.count
    if self.total_laps > 0
      if last_lap.lap_number.present? && first_lap.lap_number.present? &&
          last_lap.lap_number - first_lap.lap_number > total_laps
        self.total_laps = last_lap.lap_number - first_lap.lap_number
      end

      self.position_change = first_lap.position.to_i - last_lap.position.to_i
    end

    times = self.lap_times.green.map(&:lap_time)

    if times.count > 0

      # Find fastest lap
      self.fastest_lap_time = times.min

      # Find average
      # - Drop the highest laptime because it's likely the pit lap
      max = times.max
      times = times.reject { |t| t == max }

      if times.count > 0
        self.average_lap_time = times.reduce(:+).to_f / times.count
        self.longest_lap = times.max

        # Drop anything that's variance_filter% slower than the fastest lap for variance calculation
        times = times.reject { |t| t >= self.fastest_lap_time * (1 + variance_filter) }
        mean  = times.reduce(:+).to_f / times.count

        self.variance = times.map { |time| (time - mean) ** 2 }.reduce(:+) / times.count
        self.std_dev  = Math.sqrt(self.variance)
      else
        self.longest_lap = max
        self.average_lap_time = max
        self.variance = 0
      end

      self.stint_length = last_lap.created_at.to_i - self.created_at.to_i + self.average_lap_time
      self.stint_length = 0 if stint_length > 24 * 60 * 60
    end

    # set processed at
    self.processed_at ||= Time.now

    self.save
  end

  def stats
    event = self.event
    car_number = self.car_number
    team = self.team
    driver_name = self.driver.full_name

    puts "Event: #{event}"
    puts "CAR: ##{car_number} #{team}"
    puts "DRIVER: #{driver_name}"
    puts "Created at: #{self.created_at}"
    puts "Stop at: #{self.stop_at}"
    puts "Processed at: #{self.processed_at}"
    puts "Total laps: #{self.total_laps}"
    puts "Fastest lap: #{self.fastest_lap_time}"
    puts "Avg Lap: #{self.average_lap_time}"
  end

  def send_pit_notification
    drivers_to_receive = [Driver.nick]

    self.registration.drivers.each do |driver|
      if driver.notifications_enabled?
        drivers_to_receive << driver
      end
    end

    if drivers_to_receive.count > 0
      PitNotification.new(scan: self, drivers: drivers_to_receive).deliver
    end
  end

  def send_messages
    if self.has_pit_time?
      pit_message = "Your offical pit time for ##{self.car_number} was #{human_time(self.pit_time)}."
      if self.short_stop
        pit_message << " THIS WAS A SHORT STOP!"
      end

      if self.driver.try(:known?)
        pit_message << " #{self.driver} is in the car"
        pit_message << " Details here: https://race.americanenduranceracing.com/scans/#{self.id}"
      else
        pit_message << " DRIVER UNKNOWN PLEASE UPDATE: https://race.americanenduranceracing.com/scans/#{id}"
        SmsMessenger.to(Driver.alex, "DRIVER UNKNOWN IN CAR ##{self.car_number} #{self.car.team} (#{self.car.car_type})").send
      end

      SmsMessenger.to(self.registration, pit_message).send
    end

    if self.driver.try(:known?) and self.driver.lifetime_lap_count < 200
      SmsMessenger.to(Driver.alex, "ROOKIE DRIVER #{self.driver} (#{self.driver.lifetime_lap_count} laps) just entered Car ##{self.car_number}").send
    end
  end

  def name
    "#{driver_name} in (##{car_number} #{team} #{car.year} #{car.make}) @ #{self.created_at}" rescue nil
  end

  # For rails_admin: https://github.com/sferik/rails_admin/wiki/Enumeration
  def pit_enum
    PITS
  end

  def stop_time
    time_in_zone.strftime("%-I:%M:%S%p")
  end

  def formatted_time(summary: true)
    if in_scan.present? and summary
      "in#{in_scan.formatted_time} - out#{stop_time}"
    else
      stop_time
    end
  end

  def race_monitor_name
    if driver
      "#{driver.first_name.first}. #{driver.last_name}"
    end
  end

  def driver_name
    if driver
      "#{driver.first_name} #{driver.last_name}"
    end
  end

  def time_in_zone
    self.stop_at.in_time_zone(event.time_zone)
  end

  def validate_barcode_but_save_anyway_yolo
    # We have this because we want all scans logged cause we can't trust the HW
    if self.driver.nil?
      self.errors.add :driver, "invalid"
    end

    if self.errors.empty?
      self.response_code = 'VALID'
      self.message = "#{self.car.name} -- \##{self.registration.car_number} -- #{self.driver.full_name}"
    else
      self.response_code = 'INVALID'
      self.message = self.errors.full_messages.join(',')
      ## in order to save the model we've got to clear all the errors.
      self.errors.clear
    end
    return true
  end

  def assign_stop_time
    if self.stop_at.nil?
      self.stop_at = self.created_at
      update_column(:stop_at, self.stop_at)
    end
  end

  def can_change_driver?(changer)
    (changer.present? and self.team == changer.team) or
      (self.driver.present? and changer == self.driver)
  end

  def driver_registered_in_car?
    self.registration.driver_registrations.where(driver_id: self.driver_id).exists?
  end

  def associate_with_scan_in_job
    ScanInAssociatorJob.set(wait: 1.second).perform_later(self.id) if self.out?
  end

  rails_admin do
    list do
      filters [:registration, :driver]

      field :created_at do
        label "Time (Current: #{Time.now.to_s(:time)})"
        sort_reverse false
      end

      field :car_number

      field :driver do
        searchable [:last_name, :first_name, :barcode]
      end

      field :short_stop

      field :team
      field :pit
      field :registration do
        searchable [:car_number]
      end

      exclude_fields :id, :updated_at
    end

    show do
      field :driver
      field :lap_times

      include_all_fields
    end

    edit do
      field :registration do
        associated_collection_scope do
          proc do |scope|
            scope.where(event: Event.current).limit(30)
          end
        end

        # TODO: Remove Registration#name and put config here

        searchable [:car_number, :team]
      end

      field :driver do
        searchable [:barcode, :last_name, :first_name]
      end

      field :short_stop

      field :pit, :enum do
        default_value 'OUT'
      end
    end
  end

end
