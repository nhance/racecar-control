# create_table :rfid_reads, force: :cascade do |t|
#   t.integer  :rfid_reader_id,       limit: 4
#   t.string   :reader_role,          limit: 255
#   t.integer  :first_seen_timestamp, limit: 8
#   t.string   :antenna_port,         limit: 255
#   t.string   :epc,                  limit: 255
#   t.string   :peak_rssi,            limit: 255
#   t.string   :tid,                  limit: 255
#   t.text     :raw_request,          limit: 65535
#   t.datetime :created_at
#   t.datetime :updated_at
#   t.integer  :scan_id,              limit: 4
# end
#
# add_index :rfid_reads, [:first_seen_timestamp], name: :index_rfid_reads_on_first_seen_timestamp, using: :btree

class RfidRead < ActiveRecord::Base
  belongs_to :rfid_reader
  belongs_to :scan
  has_one :registration, through: :scan

  after_create :generate_scan_job

  scope :driver, -> { where("epc LIKE 'D%'") }
  scope :car,    -> { where("epc LIKE 'C%'") }

  scope :without_scan, -> { where(scan_id: nil) }
  scope :for_driver_ids, ->(ids) {
    barcodes = ids.map { |id| Driver.barcode_for_id(id) }

    where(epc: barcodes)
  }

  scope :before, ->(rfid_read, within: 5_000_000) {
    timestamp = rfid_read.first_seen_timestamp
    where(reader_role: rfid_read.reader_role).
    where(["first_seen_timestamp >= ? AND first_seen_timestamp < ?",
           timestamp - within,
           timestamp]).reorder("first_seen_timestamp DESC") }

  scope :after, ->(rfid_read, within: 5_000_000) {
    timestamp = rfid_read.first_seen_timestamp
    where(reader_role: rfid_read.reader_role).
    where(["first_seen_timestamp > ? AND first_seen_timestamp <= ?",
           timestamp,
           timestamp + within]) }

  default_scope -> { order("first_seen_timestamp ASC") }

  def fill_from_reader(read)
    self.raw_request = read.inspect

    self.epc                  = read['epc'] # This is where our user data is stored!
    self.first_seen_timestamp = read['first_seen_timestamp']
    self.antenna_port         = read['antenna_port']
    self.peak_rssi            = read['peak_rssi']
    self.tid                  = read['tid']

    if self.rfid_reader.present?
      self.reader_role = self.rfid_reader.role
    end
  end

  def tag_type
    first_char = self.epc[0]
    case first_char
    when 'C'
      Car
    when 'D'
      Driver
    else
      nil
    end
  end

  def before
    self.class.before(self)
  end

  def after
    self.class.after(self)
  end

  def car?
    tag_type == Car
  end

  def car
    Car.where(barcode: self.epc).first
  end

  def driver?
    tag_type == Driver
  end

  def driver
    Driver.where(barcode: self.epc).first
  end

  def reader
    rfid_reader
  end

  def first_seen_time
    # Converts the first_seen_timestamp into a time
    Time.at(first_seen_timestamp.to_i / 1_000_000.0).in_time_zone('America/New_York')
  end

  def generate_scan_job
    if self.car? and self.scan.nil? and Race.current
      ScanGeneratorJob.set(wait: 2.seconds).perform_later(rfid_read: self)
    end

    true
  end

  rails_admin do
    include_all_fields
  end
end
