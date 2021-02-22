class ManualResultsGenerator
  def initialize(file, race:)
    @race = race
    @event = @race.event
    @data = CSV.read(file, headers: true, header_converters: :symbol)
    # Expected format: No., Laps, Class, Points, Position In Class
    # CSV will map to: :no, :laps, :class, :points, :position_in_class
  end

  def generate_results
    Race.transaction do
      @data.each do |row|
        registration = @event.registrations.by_car_number(row[:no])
        if registration and last_lap = registration.lap_times.for_race(@race).last

          result = Result.new
          result.race = @race
          result.registration = registration
          result.laps = row[:laps]
          result.last_lap_at = last_lap.created_at
          result.car_class = row[:class]

          if result.save
            puts "#{row[:no]} (#{row[:laps]} laps in class '#{row[:class]}')"
          end
        end
      end
    end
  end
end
