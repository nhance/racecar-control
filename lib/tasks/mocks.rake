desc "Create a fake current event"
task :mock_event => :environment do
  require 'factory_girl'

  FactoryGirl.find_definitions

  event = Event.current
  event ||= FactoryGirl.create(:event, :current, track: "Watkins Glen")

  FactoryGirl.create(:race, event: event)
end

desc "Setup the database to fake a race (RESETS DATABASE)"
task :fake_a_race => :environment do
  require 'factory_girl'
  #Rake::Task["db:reset"].invoke
  FactoryGirl.find_definitions

  # We're working from a known dataset, so let's load the data as if we
  # already have our side set up
  # Data source: examples/aer_wgi_day_2.csv

  FactoryGirl.create(:event, :current, track: "Watkins Glen") if Event.current.nil?

  event = Event.current

  FactoryGirl.create(:race, event: event)

  data_source = 'examples/aer_wgi_day_2.csv'
  File.open(data_source, "r") do |f|
    f.each_line do |line|
      scoreboard_message = ScoreboardMessage.parse(line)

      if scoreboard_message.a? and scoreboard_message.car_number != "-??-"
        registration = event.registrations.by_car_number(scoreboard_message.car_number)
        first_name, last_name = scoreboard_message.driver_name.split(" ", 2)
        team_name = scoreboard_message.team_name

        if registration.blank?
          team = Team.find_by(name: team_name) ||
                   FactoryGirl.create(:team, name: team_name)

          driver = Driver.find_by(first_name: first_name, last_name: last_name) ||
                    FactoryGirl.create(:driver, first_name: first_name,
                                               last_name: last_name,
                                               team: team)

          car = Car.find_by(transponder_number: scoreboard_message.transponder) ||
                  FactoryGirl.create(:car, team: team, transponder_number: scoreboard_message.transponder)

          registration = FactoryGirl.create(:registration, car: car,
                                               car_number: scoreboard_message.car_number,
                                               event: event)

          scan = FactoryGirl.create(:scan, registration: registration, driver: driver)

          puts "Registered #{driver}/#{team} in #{car} (##{registration.car_number})"
        end
      end
    end

    puts "-" * 80
    puts "\n\n"
    puts "Race data has been loaded. You can run this race in simulation mode by"
    puts "running: bin/orbits_simulator_server.rb"
    puts "Then run AerOrbitsConsumer.start in a console and connect to localhost on port 50002"
    puts "to kick off the whole process"
  end
end
