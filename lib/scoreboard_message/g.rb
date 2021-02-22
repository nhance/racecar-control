# POSITION data
# $G,1,"747",165,"07:46:59.136"
# $G, race order by position, "carnumber", current lap, "total race time"
# Sent during each passing
class ScoreboardMessage::G < ScoreboardMessage
  fields :command, :position, "registration_number", :current_lap, "total_race_time"
end
