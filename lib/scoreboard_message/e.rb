# $E,"TRACKNAME","Watkins Glen Internation"
# $E, "VARNAME", "Var value"
# Variable data
#
# Valid name values:
#   - TRACKNAME
#   - TRACKLENGTH
class ScoreboardMessage::E < ScoreboardMessage
  fields :command, "name", "value"
end
