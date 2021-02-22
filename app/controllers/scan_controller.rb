class ScanController < ApplicationController
  def ssl_required?
    false
  end

  # Used for outdated Barcode reader stuff
  def create
    # REFACTOR ME, PLEASE?
    #
    pit = params[:pit]
    if params[:car] =~ /^\d+$/
      car_barcode = "C#{params[:car]}"
    else
      car_barcode = params[:car]
    end

    driver_barcode = params[:driver]

    driver = Driver.find_by(barcode: driver_barcode)
    car = Car.find_by(barcode: car_barcode)

    event = Event.current

    if event.present? && car.present?
      registration = event.registrations.find_by(car_id: car.id)
    else
      registration = nil
    end

    # ????????
    audit = ScanAudit.new
    audit.barcode = car_barcode
    audit.pit = pit
    audit.response_code = (car.nil?) ? 'INVALID' : 'VALID'
    audit.message = (car.nil?) ? 'Car not found' : ''
    audit.save!

    audit = ScanAudit.new
    audit.barcode = driver_barcode
    audit.response_code = (driver.nil?) ? 'INVALID' : 'VALID'
    audit.pit = pit
    audit.message = (driver.nil?) ? 'Driver not found' : ''
    audit.save!
    # /???????????

    scan = Scan.create(
      pit: pit,
      registration: registration,
      driver: driver
    )
    scan.save

    render text: "#{scan.response_code} :: #{scan.message}"

    begin
      if previous_scan = scan.previous
        previous_scan.process!
      end
    rescue
      # ignored
    end
  end
end
