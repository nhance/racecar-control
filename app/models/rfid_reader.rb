# create_table :rfid_readers, force: :cascade do |t|
#   t.string   :name,            limit: 255
#   t.string   :mac_address,     limit: 255
#   t.string   :role,            limit: 255
#   t.string   :last_ip_address, limit: 255
#   t.datetime :created_at
#   t.datetime :updated_at
# end

class RfidReader < ActiveRecord::Base
  RFID_ROLES = Scan::PITS

  validates :role, inclusion: { in: RFID_ROLES }

  has_many :rfid_reads

  def reader_post(ip_address: nil, params:)
    self.update_attribute(:last_ip_address, ip_address)

    shared_params = { reader_name: params['reader_name'],
                      mac_address: params['mac_address'] }

    line_ending   = params['line_ending'] || "\n"
    field_delim   = params['field_delim'] || ','

    field_values  = params['field_values'] || ""
    field_names   = params['field_names']  || "antenna_port,epc,first_seen_timestamp,peak_rssi,tid"

    headers = field_names.split(',')

    reads = 0

    field_values.split(line_ending).each do |line|
      read = {}

      values = line.split(field_delim)
      values.each_with_index do |value, index|
        read[headers[index]] = value.gsub('"', '')
      end

      read.merge(shared_params)

      rfid_read = self.rfid_reads.new
      rfid_read.fill_from_reader(read)

      if rfid_read.save
        reads += 1
      else
        Rails.logger.info "Read create failed: #{rfid_read.errors.inspect} -- #{rfid_read.inspect}"
      end
    end

    Rails.logger.info "Processed #{reads} read(s)"

    reads
  end

  rails_admin do
    include_all_fields
  end
end
