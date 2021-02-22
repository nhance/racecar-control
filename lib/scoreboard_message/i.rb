# INIT RECORD
# THIS CLEARS RACEMONITOR CLIENTS!!
# $I,"16:36:08.080","03 nov 14"
# $I,"current_time","dd_mmm_yy"
class ScoreboardMessage::I < ScoreboardMessage
  fields :command, "current_time", "dd_mmm_yy"
end
