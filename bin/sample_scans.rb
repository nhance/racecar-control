#!/usr/bin/env ./bin/rails runner

dc = Driver.count
event = Event.last

Team.all.each do |team|
  puts team.team_name
  puts Driver.find( rand( dc - 1 ) + 1 ).driver_name
  scan = Scan.new( team: team, 
                   driver: Driver.find( rand( dc - 1 ) + 1 ),
                   pit: 'OUT',
                   event: event
  )
  scan.save!
end
