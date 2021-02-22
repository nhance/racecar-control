# RACE data
# $B,95,"Saturday Race1"
# $B, run number, "Description"
class ScoreboardMessage::B < ScoreboardMessage
  fields :command, :run_number, "description"

  def qualifying?
    description.downcase.include?('qualifying')
  end
end
