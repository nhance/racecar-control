module LapTimeHelper

  HOUR_IN_SECONDS = 60 * 60
  NO_TIME = 9999.99

  # TODO: Will need to do these by Event.
  def fastest_lap_time
    # if no times exist, return 9999.99.  like setting no time
    # and moves them to the bottom of the list!
    self.lap_times.race.pluck(:lap_time).min || NO_TIME
  end

  def fastest_lap_speed(event=Event.last)
    (event.track_length / ( self.fastest_lap_time / HOUR_IN_SECONDS )).round(3) rescue 0.0
  end

  # TODO: Will need to do these by Event.
  def fastest_qualifying_time
    # if no times exist, return 9999.99.  like setting no time
    # and moves them to the bottom of the list!
    self.lap_times.quali.pluck(:lap_time).min || NO_TIME
  end

  def fastest_qualifying_speed(event=Event.last)
    (event.track_length / ( self.fastest_qualifying_time / HOUR_IN_SECONDS )).round(3) rescue 0.0
  end

  # TODO: Will need to do these by Event.
  def self.teams_by_lap_time
    Team.all.sort{|a,b| a.fastest_lap_time.to_f <=> b.fastest_lap_time.to_f}
  end

  # TODO: Will need to do these by Event.
  def self.teams_by_qualifying_time
    Team.all.sort{|a,b| a.fastest_qualifying_time.to_f <=> b.fastest_qualifying_time.to_f}
  end

  # Makes code a little cleaner vs teams[0].fastest_lap_time
  # but could be slower. So I'm debating it's usefulness.
  def self.ftd
    self.teams_by_lap_time[0].fastest_lap_time
  end

  def self.qualifying_ftd
    self.teams_by_qualifying_time[0].fastest_qualifying_time
  end
end
