# Heartbeat, sent every second
# $F,9999,"00:00:00","15:26:46","06:40:30","Green "
# $F, laps to go, "time to go", "local time in 24hr format", "hot track time", "track status (6 chars with trailing spaces)"
class ScoreboardMessage::F < ScoreboardMessage
  fields :command, :laps_to_go, "time_to_go", "current_time", "race_time", "track_status"

  def track_status
    @track_status.ljust(6) # Ensures the string is always 6 chars long with trailing spaces. (See spec)
  end
end
