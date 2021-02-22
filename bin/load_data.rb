#!/usr/bin/env ./bin/rails runner

require 'csv'

CSV.foreach( './tmp/20141017-JBWGI-2.csv', { headers: true } ) do |row|
  puts "team captain: '#{row.field('Segment Name')}'"
  puts "\theaders: '#{row.headers}'"
  captain = false
  car = nil
  if 'Team Captains' == row.field('Segment Name')
    puts "FOUND CAPTAIN!"
    # puts "Transponder: '#{row.field('Transponder ID').to_s}'"
    barcode = row.field('Transponder ID').to_s
    car_number  = row.field('No.').to_s
    car = Car.find_by_barcode barcode
    if car.nil? || barcode.blank?
      car = Car.find_by_car_number_and_barcode car_number, ''
    end
    car = Car.new if car.nil?

    captain = true
    car.barcode = barcode
    car.car_number  = car_number
    car.car_class   = row.field('Class')
    car.info    = row.field('Vehicle Year/Make/Model/Color')
    car.event_id = 1
    car.save! if car.changed?
  end

  barcode = 'D' + row.field('Unique ID')
  driver = Driver.find_by_barcode( barcode )
  driver = Driver.new if driver.nil?

  driver.barcode    = 'D' + row.field('Unique ID')
  driver.first_name = row.field('First Name')
  driver.last_name  = row.field('Last Name')
  # puts "HERE07"
  driver.email      = row.field('E-mail')
  # puts "HERE08"
  driver.captain    = captain
  driver.save! if driver.changed?

  if captain
    driver.reload
    car.reload
    puts "Creating TEAM"
    name = row.field('team name')
    team = Team.find_by_team_name name
    team = Team.new if team.nil?
    team.name = name
    team.captain_id = driver.id
    team.car_id = car.id
    team.event_id = 1
    team.save! if team.changed?
  end
end
