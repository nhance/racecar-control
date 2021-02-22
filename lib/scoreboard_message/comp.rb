# $COMP,"74","74",1,"Happy Moose Racing","Randy Pobst","",""
# $COMP, "car number", "car number", class number, "first_name (9 character limit)", "last_name (30 char limit)", "nationality(50)", "additional data (50)"
class ScoreboardMessage::Comp < ScoreboardMessage
  fields :command, "registration_number", "car_number", :class_number, "first_name", "last_name", "nationality", "additional"

  include TeamNameHelpers
end
