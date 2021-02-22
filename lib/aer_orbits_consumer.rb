require 'socket'

require 'race_monitor_server'
require 'orbits_connection'
require 'scoreboard_message'

class AerOrbitsConsumer
  ORBITS_IP_ADDRESS = '127.0.0.1'
  ORBITS_PORT = 50000

  attr_accessor :drivers, :positions, :last_laps, :track_status, :qualifying, :a_records, :comp_records, :event

  def initialize
    @a_records    = Hash.new("")  # Holds $A records for each car, because we want to yield to orbits
    @comp_records = Hash.new("")  # Holds $COMP records for each car, because we want to yield to orbits
    @drivers      = Hash.new { |hash, key| hash[key] = CurrentDriver::driving_car(key).try(:name) }
    @positions    = {}
    @last_laps    = {}
    @track_status = nil
    @qualifying   = false
    @event        = Event.current
  end

  def self.start
    consumer = new
    consumer.start
  end

  def start
    begin
      loop do
        Thread.start(race_monitor.accept) do |client|
          begin
            print "connection accepted\n"
            # Theroy: Because each connection connects to orbits, it should send a refresh.
            # What does race monitor relay do? It has it's own logic like what we do here.
            orbits = OrbitsConnection.connect(ORBITS_IP_ADDRESS, ORBITS_PORT)
            while orbits_msg = orbits.get_scoreboard_message
              map_scoreboard_message(orbits_msg, client)
            end
          rescue Errno::ECONNABORTED, Errno::EPIPE => e
            puts "Client left, closing connections"
            orbits.close
            client.close
          rescue Exception => e
            puts "Caught loop exception #{e.class}: #{e}"
            puts e.backtrace.join("\n")
            orbits.close
            client.close
            raise e
          end
        end
      end
    rescue SignalException, IRB::Abort => e
      puts "Caught interrupt"
    rescue Exception => e
      puts "Caught exception #{e.class}"
      raise e
    ensure
      # shutdown?
      self.stop
    end
  end

  def stop
    race_monitor.close
  end

  private

  def race_monitor
    @race_monitor_server ||= RaceMonitorServer.new
  end

  def map_scoreboard_message(scoreboard_message, client)
    # A and COMP records come in anytime there's a change to driver info.
    # Example: We changed a class for a car and it generated both a COMP and an A record
    # WE need to intercept and modify these on the fly.
    if scoreboard_message.a? or scoreboard_message.comp?
      car_number = scoreboard_message.registration_number
      if scoreboard_message.driver_name != drivers[car_number]
        scoreboard_message.driver_name = drivers[car_number]
        if registration = event.registrations.by_car_number(car_number)
          if scan = registration.last_pit_out
            scoreboard_message.team_name = registration.car_name
            scoreboard_message.driver_name = scan.driver_name
          end
        end
      end

      if scoreboard_message.a?
        a_records[car_number] = scoreboard_message
      elsif scoreboard_message.comp?
        comp_records[car_number] = scoreboard_message
      end
    end

    if scoreboard_message.f?
      self.track_status = scoreboard_message.track_status
    end

    # NOTE: Each passing generates a G (position ranking), H (Laptime ranking), and J (Passing/timing) record for each car

    # Passing Information
    if scoreboard_message.j?
      scan = nil
      car_number = scoreboard_message.registration_number

      if registration = event.registrations.by_car_number(car_number)
        scan = registration.last_pit_out
        puts scan.inspect
        if scan.present?
          if scan.driver_name != drivers[car_number]
            drivers[car_number] = scan.driver_name
            announce_driver(car_number, client)
          end
        end
      end

      # This means if we don't have your car scanned, your laptimes won't count.
      last_laps[car_number] = record_laptime(scoreboard_message, scan)
    end

    # Position information (Must appear after $J processing for laptime update)
    if scoreboard_message.g?
      car_number = scoreboard_message.registration_number
      if lap = last_laps[car_number]
        lap.position = scoreboard_message.position
        lap.lap_number = scoreboard_message.current_lap
        lap.save
      end
    end

    if scoreboard_message.b?
      @qualifying = scoreboard_message.qualifying?
    end

    puts scoreboard_message
    client.write(scoreboard_message)
  end

  def announce_driver(car_number, client)
    if registration = event.registrations.by_car_number(car_number)
      scan = registration.last_pit_out

      team_name   = registration.car_name
      driver_name = scan.driver_name

      a_record = a_records[car_number]
      comp_record = comp_records[car_number]

      a_record.driver_name = driver_name
      comp_record.driver_name = driver_name

      a_record.team_name = team_name
      comp_record.team_name = team_name

      a_records[car_number] = a_record
      comp_records[car_number] = comp_record
    end

    puts a_records[car_number]
    client.write a_records[car_number]

    puts comp_records[car_number]
    client.write comp_records[car_number]
  end

  def record_laptime(scoreboard_message, scan)
    # Data order is always $J followed by $G and $H
    if scoreboard_message.lap_seconds > 0
      LapTime.create(scan: scan,
                     lap_time: scoreboard_message.lap_seconds,
                     car_number: scoreboard_message.registration_number,
                     track_status: track_status,
                     qualifying: qualifying)
    end
  end
end
