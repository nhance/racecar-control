class RfidReadsController < ApplicationController
  before_filter :require_admin, only: [:index, :show]
  skip_before_filter :verify_authenticity_token

  def index
    rfid_reads = RfidRead.unscoped.order('first_seen_timestamp DESC')

    if params[:tag].present?
      rfid_reads = rfid_reads.where(epc: params[:tag])
    end

    if params[:car_number].present?
      if car = Car.current.find_by(number: params[:car_number])
        rfid_reads = rfid_reads.where(epc: car.barcode)
      end
    end

    if params[:position].present?
      rfid_reads = rfid_reads.where(reader_role: params[:position])
    end

    if params[:today].present?
      rfid_reads = rfid_reads.where(["first_seen_timestamp >= ?", Date.today.beginning_of_day.to_i * 1_000_000])
    end

    @rfid_reads = rfid_reads.page(params[:page]).per(50)
  end

  # This is where the RFID Reads are hit.
  # TODO: This is sent in plaintext, meaning a sneaky racer could submit their own pit timing.
  #
  # What could happen is someone could disable the tag in their car and watch on the sidelines
  # and submit their own requests to this endpoint.
  #
  # The RFID readers are Impinj Speedway Revolution devices:
  # https://www.impinj.com/products/readers/impinj-speedway
  #
  # I'm not sure if authentication is supported, so we used the MAC address to determine which device is sending the reads.
  # See the automated tests for details on how these are sent.
  #
  # An RFID box consists of
  # - Impinj Speedway revolution
  # - Digi Cellular internet provider
  # - Weidmuller connect power device to provide power via car batteries
  # - 15amp fuse
  # - Small 4 port switch
  # - 2 RFID antennas connected to impinj device
  # - 2 cellular antennas connected to the digi device
  #
  # MAC Address is the address of the RFID reader. The cell connector is invisible to us here.
  def create
    RfidTest.create(params: rfid_params)
    mac_address = params[:mac_address].gsub('"', '')

    rfid_reader = RfidReader.where(mac_address: mac_address).first

    if rfid_reader.present?
      if rfid_reader.reader_post(ip_address: request.remote_ip, params: rfid_params) > 0
        head :ok
      else
        Rails.logger.warn "No reads processed from #{rfid_params.inspect}"
        head :unprocessable_entity
      end
    else
      Rails.logger.warn "No reader defined for mac address #{mac_address}"
      head :unprocessable_entity
    end
  end

  def rfid_params
    params.to_unsafe_h.except("controller", "action")
  end
end
