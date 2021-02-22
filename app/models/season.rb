# create_table :seasons, force: :cascade do |t|
#   t.integer :event_price_in_cents,  limit: 4
#   t.date    :start_date
#   t.integer :points_eligible_races, limit: 4
# end

class Season < ActiveRecord::Base
  has_many :events
  has_many :cars

  has_many :races, through: :events

  DEFAULT_EVENT_PRICE_IN_CENTS = 1800_00

  before_create :assign_defaults

  def self.current
    begin
      where(["seasons.start_date <= ?", Date.today]).order("seasons.id DESC").first
    rescue ActiveRecord::RecordNotFound
      current_season_id = Date.today.year
      create(id: current_season_id)
    end
  end

  def self.[](season_id)
    find(season_id)
  end

  def assign_defaults
    self.start_date           ||= Date.parse("#{self.id}-01-01")
    self.event_price_in_cents ||= DEFAULT_EVENT_PRICE_IN_CENTS
  end

  def year
    id
  end

  def standings
    standings = {} # { { instance_of(Car): [event.points, event.points, ...] } }

    self.events.each do |event|
      event_standings = {}
      event_results = Result.where(race_id: event.race_ids)
      event_results.each do |result|
        car = result.car
        next unless car.present?

        if result.points_with_adjustments != 0
          event_standings[car] ||= []
          event_standings[car] << result.points_with_adjustments
        end
      end

      event_standings.each do |car, points_array|
        standings[car] ||= []
        standings[car] << points_array.reduce(0, :+)
      end
    end

    # Now we must collapse the array of points to a scalar value
    # If we specify a number of eligible races, we must drop the lowest points past the number
    # of eligible races
    standings.each do |car, points_array|
      points_array.sort!.reverse! # Reorder the results so largest are first
      if self.points_eligible_races.to_i > 0
        standings[car] = points_array.slice(0, self.points_eligible_races).reduce(0, :+)
      else
        standings[car] = points_array.reduce(0, :+)
      end
    end

    standings.sort_by {|k,v| v}.reverse.to_h
  end

end
