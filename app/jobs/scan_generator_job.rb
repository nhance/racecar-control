class ScanGeneratorJob < ActiveJob::Base
  queue_as :default

  def perform(rfid_read:)
    # Takes an RFID read for a car
    # Finds the closest matching registered driver
    # Creates a scan (IN or OUT depending on role)
    # Assigns scan_at time to the timestamp of the car's rfid read
    # If matching driver cannot be found, assigns scan to "UNKNOWN" driver

    @rfid_read = rfid_read

    scan = Scan.new
    scan.stop_at = @rfid_read.first_seen_time
    scan.pit = @rfid_read.reader_role
    scan.registration = registration
    scan.driver = driver

    if scan.save
      rfid_read.update_column(:scan_id, scan.id) if rfid_read.present?
      driver_rfid_read.update_column(:scan_id, scan.id) if driver_rfid_read.present?
      # scan.send_pit_notification
      true
    else
      Rails.logger.info "Scan could not be created from RFID read! Scan errors: #{scan.errors.inspect} RFID read: #{@rfid_read.inspect} RFID driver: #{driver_rfid_read.inspect}"
      false
    end
  end

  private

  def registration
    @registration ||= Registration.where(event: Event.current, car: @rfid_read.car).first
  end

  def driver_rfid_read
    reads_before = RfidRead.driver.without_scan.before(@rfid_read)
    reads_after  = RfidRead.driver.without_scan.after(@rfid_read)

    driver_before = extract_driver_read(reads_before)
    driver_after  = extract_driver_read(reads_after)

    if driver_before && driver_after
      delta_before = @rfid_read.first_seen_timestamp - driver_before.first_seen_timestamp
      delta_after  = driver_after.first_seen_timestamp - @rfid_read.first_seen_timestamp

      if delta_before < delta_after
        driver_read = driver_before
      else
        driver_read = driver_after
      end
    else # driver_before or driver_after are nil
      driver_read = driver_before || driver_after
    end

    driver_read
  end

  def driver(refresh: false)
    return @driver unless @driver.nil? or refresh

    if driver_read = driver_rfid_read
      @driver = driver_read.driver
    else
      @driver = Driver.unknown
    end
  end

  def extract_driver_read(reads)
    registered_driver_ids = registration.try(:registered_driver_ids) || []
    if driver_read = reads.find { |read| read.driver.present? and registered_driver_ids.include?(read.driver.id) }
      driver_read
    elsif reads.count == 1
      # Wait a second so other threads can pick up the driver
      sleep 1

      # Now make sure the driver is not assigned.
      read = reads.first
      read.reload

      if read.scan.blank? and read.driver.present?
        read
      end
    else
      nil
    end
  end
end
