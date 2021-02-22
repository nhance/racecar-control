#!/usr/bin/env ./bin/rails runner

require 'csv'

# awk -F, '{print $4","$2}' A_records.txt | sort -u > transponder_ids.txt
=begin
i = 0
cars = Car.all
File.open('./tmp/transponder_ids.txt', 'r') do |f1|  
  while line = f1.gets
    parts = line.split(',')
    puts "#{parts[0].strip} #{parts[1].strip}"
    cars[i].barcode = parts[0].strip
    cars[i].car_number = parts[1].strip.tr('"','')
    cars[i].save!
    i += 1
  end  
end  
=end

fo = File.new( 'tmp/AER_simulated_data.txt', 'w' )
CSV.foreach( 'tmp/ALMS_Session4.txt' ) do |row|
  if row[0] == '$A' || row[0] == '$COMP'
    car_number = row[1].tr('"','')
    car = Car.find_by_car_number car_number
    if car.present?
      puts car.team.team_name
      row[4] = car.team.team_name
    end
  end

  fo.puts row.join(',')
end
fo.close
