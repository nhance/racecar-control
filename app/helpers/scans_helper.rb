module ScansHelper
  def css_class_for(lap_time)
    classes = []
    classes << lap_time.track_status
    classes << "fastest" if lap_time.fastest?

    classes
  end

  def human_time(duration)
    duration ||= 0
    hours   = (duration / (60 * 60)).to_i
    minutes = (duration / 60) % 60
    seconds = duration % 60

    human_lap_time = "%02d:%06.3f" % [minutes, seconds]

    if hours > 0
      human_lap_time = "#{("%02d" % hours)}:#{human_lap_time}"
    end

    human_lap_time
  end
end
