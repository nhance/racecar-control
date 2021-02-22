class ScanInAssociatorJob < ActiveJob::Base
  queue_as :default

  include ScansHelper

  def perform(scan_id)
    # Takes an OUT scan and locates the matching scan IN for it
    # Will only look within the bounds of the race for which the scan is located.

    scan = Scan.find(scan_id)
    return nil unless scan.out?

    matched_in = Scan.in.for_race(scan.race).where(["stop_at < ?", scan.stop_at]).
                    where(registration_id: scan.registration_id).reorder("stop_at DESC").first

    if matched_in.present? and matched_in.out_scan.nil?
      scan.in_scan = matched_in
      if scan.has_pit_time? and scan.pit_time < Scan::MIN_PIT_TIME
        scan.short_stop = true
      end
    else
      scan.short_stop = true
    end

    if scan.save
      scan.send_messages
      true
    else
      Rails.logger.info "SCAN NOT SAVED: #{scan.errors.full_messages.inspect}"
    end
  end
end
