# create_table :races, force: :cascade do |t|
#   t.integer  :event_id,   limit: 4
#   t.string   :name,       limit: 255
#   t.datetime :start_time
#   t.datetime :end_time
#   t.boolean  :qualifying,             default: false
# end
#
# add_index :races, [:event_id], name: :index_races_on_event_id, using: :btree

class Race < ActiveRecord::Base
  belongs_to :event
  has_many :results

  @@current_race = nil

  scope :race, ->{ where(qualifying: false) }

  def self.current
    if @@current_race.nil?
      race = find_by("start_time <= ? AND end_time >= ?", Time.now.utc, Time.now.utc)
      if race.nil? && Event.current.present?
        race = Event.current.races.where("start_time <= ?", Time.now.utc).last
      end

      race
    else
      @@current_race
    end
  end

  def self.finish!
    race = self.current
    if race.nil?
      puts "NO CURRENT RACE"
      return
    end

    if race.finish!
      puts "RACE RESULTS ARE AVAILABLE ONLINE"
    else
      puts "RACE RESULTS NOT GENERATED. NO SCANS FOUND."
    end
  end

  def scans
    Scan.for_race(self)
  end

  def hour_timestamps
    (start_time.beginning_of_hour.to_i..end_time.to_i).step(1.hour).to_a
  end

  def lap_times
    LapTime.for_race(self)
  end

  def formatted_start_time
    time_format(:start_time)
  end

  def formatted_end_time
    time_format(:end_time)
  end

  def finish!
    return false if scans.count == 0

    scans.unprocessed.each(&:process!)

    generate_results!

    return true
  end

  def generate_results!(point_offset: nil)
    self.results.destroy_all
    create_results

    unless qualifying?
      if point_offset.present?
        @point_offset = point_offset
      end

      assign_points_and_positions
    end

    results
  end

  def car_classes(refresh: false)
    @car_classes = false if refresh
    @car_classes ||= results.order("car_class DESC").pluck(:car_class).uniq
  end

  def pretty_winners(top: 3)
    #ugly. who cares.

    pretty_winners = {}

    car_classes.each do |car_class|
      winners = results.where(car_class: car_class).order(:position).limit(top).map do |result|
        {
          car: "##{result.registration.car_number} #{result.team}",
          position: result.position,
          points: result.points_with_adjustments
        }
      end

      pretty_winners[car_class] = winners
    end

    pretty_winners
  end

  def self.sorter_by_laps_then_time
    Proc.new do |a, b|
      if a.laps > b.laps
        -1
      elsif a.laps < b.laps
        1
      else
        if a.last_lap_at > b.last_lap_at
          1
        elsif a.last_lap_at < b.last_lap_at
          -1
        else
          0
        end
      end
    end
  end

  def assign_points_and_positions
    classes = results.group_by(&:car_class)

    classes.each_pair do |class_name, run_group|
      position = 1
      min_laps = 0

      run_group.sort!(&Race.sorter_by_laps_then_time)

      run_group.each do |result|
        result.position = position

        # AER 2017.5.1 povision 7.3.: Points and award will only be given
        # to cars that have finished at least fifty percent of the
        # laps of their class winner.
        #
        if result.position == 1
          min_laps = (result.laps * 0.5).to_i
        end

        if result.laps.to_i >= min_laps.to_i
          # Adds points depending on race
          result.points = point_offset

          puts "#{result.laps} >= #{min_laps}"

          # Points earned for position
          case position
          when 1
            result.points += 25
          when 2
            result.points += 18
          when 3
            result.points += 15
          when 4
            result.points += 12
          when 5
            result.points += 10
          when 6
            result.points += 8
          when 7
            result.points += 6
          when 8
            result.points += 4
          when 9
            result.points += 2
          when 10
            result.points += 1
          end
        end

        result.save
        position += 1
      end
    end
  end

  def name_with_event
    if event.present?
      "#{event.abbr} - #{name}"
    else
      name
    end
  end

  rails_admin do
    object_label_method { :name_with_event }

    list do
      field :event
      field :name
      field :start_time do
        formatted_value { "#{bindings[:object].start_time.utc.strftime("%-H:%M")} UTC - #{bindings[:object].formatted_start_time} local" }
      end
      field :end_time do
        formatted_value { "#{bindings[:object].end_time.utc.strftime("%-H:%M")} UTC - #{bindings[:object].formatted_end_time} local" }
      end
      field :qualifying
    end
  end

  def create_results(save=true)
    new_results = []

    event.registrations.each do |registration|
      # How this works:
      #     Find the last lap for each registration, use the data in
      #     that to generate official results.
      #     This allows us to modify things in orbits and use anyone who knows how to use
      #     orbits to run our races.

      if qualifying?
        laptime = registration.lap_times.for_race(self).reorder(:lap_time).first

        if !laptime
          # If a car is registered but doesn't turn a qualifying lap, we will still allow them to race
          laptime = registration.lap_times.build(lap_number: 0, created_at: Time.now)
        end
      else
        laptime = registration.lap_times.for_race(self).last
      end

      if laptime
        if laptime.finish?
          # If we have a finish lap for the car, we want to grab the first
          # finish lap in case they died after finish
          #
          # If someone hits finish early, shit will be all fucked up.
          laptime = registration.lap_times.finish.for_race(self).first
        end
        results_params = {
          registration: registration,
          laps: laptime.lap_number,
          last_lap_at: laptime.created_at,
          lap_time_id: laptime.id,
          car_class: registration.car_class }

        if save
          new_results << results.create(results_params)
        else
          new_results << results.build(results_params)
        end
      end
    end

    new_results.sort!(&Race.sorter_by_laps_then_time)
  end

  private

  def time_format(time_method)
    send(time_method).in_time_zone(event.time_zone).strftime("%-I:%M %p")
  end

  def max_laps
    @max_laps ||= results.maximum(:laps)
  end

  def point_offset
    return @point_offset if @point_offset.present?

    if start_time.in_time_zone(event.time_zone).sunday?
      @point_offset = 3
    else
      @point_offset = 0
    end

    @point_offset
  end

end
