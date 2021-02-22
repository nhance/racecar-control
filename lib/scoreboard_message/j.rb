# $J,"87","00:02:24.963","06:31:22.801"
# PASSING - A passing is a entered when a car crosses the loop
# Format:
# $J, "car number", "lap time", "recorded at"
class ScoreboardMessage::J < ScoreboardMessage
  fields :command, "registration_number", "laptime", "recorded_at"

  def lap_seconds
    return 0.0 if laptime.nil?
    segments = laptime.split(':')
    secs  = ( segments[0].to_i * 60 * 60 ) + # hours
            ( segments[1].to_i * 60 ) +      # mins
            segments[2].to_f                 # secs
    return secs
  end
end
