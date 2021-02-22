class PitNotification
  def initialize(scan:, drivers:)
    @scan = scan
    @drivers = drivers
  end

  def deliver
    if $fcm.send(tokens, data: payload, priority: "high", "content_available": true)
      payload
    end
  end

  private
  def tokens
    @drivers.map(&:fcm_token)
  end

  def payload
    {
      messageType: "Scan",
      pit: @scan.pit,
      stop_at: @scan.stop_at.in_time_zone(@scan.event.time_zone).strftime("%F %T"),
      car_number: @scan.car_number,
      car: @scan.car.car_type,
      team: @scan.team,
      driver: @scan.driver_name
    }
  end
end
