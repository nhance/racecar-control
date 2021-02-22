# $H,19,"114",130,"00:02:27.703"
# $H, race order by laptime, "car number", lap where fast time set, "fastest lap time"
# LAPTIME
# Sent during each passing
# Sent on refresh
class ScoreboardMessage::H < ScoreboardMessage
  fields :command, :position, "registration_number", :best_lap, "best_laptime"
end
