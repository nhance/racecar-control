# create_table :rfid_tests, force: :cascade do |t|
#   t.text :params,           limit: 65535
#   t.text :expected_to_read, limit: 65535
# end

class RfidTest < ActiveRecord::Base
  serialize :params

  rails_admin do
    list do
      field :id
      field :reader_name
      field :mac_address
      field :tag_count
      field :rows
      field :tags
    end

    show do
      field :id
      field :params
      field :tag_count
      field :tags
    end

    edit do
      field :expected_to_read
    end
  end

  def reader_name
    if params["reader_name"]
      sanitize params["reader_name"]
    end
  end

  def mac_address
    if params["mac_address"]
      sanitize params["mac_address"]
    end
  end

  def tags
    if @tags.nil?
      @tags = []

      rows.each do |row|
        tag = HashWithIndifferentAccess.new

        headers.each_with_index do |header, index|
          tag[header] = sanitize(row[index])
        end

        @tags << tag
      end

      @tags
    end
  end

  def tag_count
    tags.try(:count).to_i
  end

  def headers
    @headers ||= if params["field_names"]
      params["field_names"].split(",")
    end
  end

  def rows
    @rows ||= if headers and fields = params["field_values"]
      fields = fields.split(params["line_ending"])
      fields.map { |row| row.split(params["field_delim"]) }
    end
  end

  private
  def sanitize(string)
    string.gsub('"', '')
  end
end
