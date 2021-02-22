# $A,"74","74",811627,"Happy Moose Racing","Randy Pobst","",1
# $A, "registration_number", "car_number", transponder, "first_name", "last_name", "nationality", class number
#
# Limitations:
# first_name: 9 characters
# last_name: 30 characters
# nationality: 50 characters
#
class ScoreboardMessage::A < ScoreboardMessage
  fields :command, "registration_number", "car_number", :transponder, "first_name", "last_name", "nationality", :class_number

  include TeamNameHelpers
end
