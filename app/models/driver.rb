# create_table :drivers, force: :cascade do |t|
#   t.string   :barcode,                 limit: 255
#   t.string   :first_name,              limit: 255
#   t.string   :last_name,               limit: 255
#   t.string   :email,                   limit: 255
#   t.datetime :created_at
#   t.datetime :updated_at
#   t.string   :cell_phone,              limit: 255
#   t.string   :encrypted_password,      limit: 255,   default: "",   null: false
#   t.string   :reset_password_token,    limit: 255
#   t.datetime :reset_password_sent_at
#   t.datetime :remember_created_at
#   t.integer  :sign_in_count,           limit: 4,     default: 0,    null: false
#   t.datetime :current_sign_in_at
#   t.datetime :last_sign_in_at
#   t.string   :current_sign_in_ip,      limit: 255
#   t.string   :last_sign_in_ip,         limit: 255
#   t.string   :confirmation_token,      limit: 255
#   t.datetime :confirmed_at
#   t.datetime :confirmation_sent_at
#   t.string   :unconfirmed_email,       limit: 255
#   t.string   :street_address,          limit: 255
#   t.string   :city,                    limit: 255
#   t.string   :state,                   limit: 255
#   t.string   :zip_code,                limit: 255
#   t.string   :emergency_contact_name,  limit: 255
#   t.string   :emergency_contact_phone, limit: 255
#   t.text     :details,                 limit: 65535
#   t.integer  :team_id,                 limit: 4
#   t.string   :referred_by,             limit: 255
#   t.boolean  :allow_sms,                             default: true
#   t.string   :shirt_size,              limit: 255
#   t.datetime :approved_at
#   t.string   :fcm_token,               limit: 255
#   t.integer  :lap_count_adjustment,    limit: 4,     default: 0
#   t.text     :notes,                   limit: 65535
#   t.text     :admin_notes,             limit: 65535
# end
#
# add_index :drivers, [:barcode], name: :index_drivers_on_barcode, using: :btree
# add_index :drivers, [:email], name: :index_drivers_on_email, unique: true, using: :btree
# add_index :drivers, [:reset_password_token], name: :index_drivers_on_reset_password_token, unique: true, using: :btree

class Driver < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable

  serialize :details, JSON

  has_paper_trail

  include LapTimeHelper
  include BarcodeCapable

  validates_presence_of :first_name, :last_name, :email, :emergency_contact_name, :emergency_contact_phone
  validates_uniqueness_of :email

  validates_presence_of :cell_phone, :shirt_size, if: :require_extra_validation?
  validates_presence_of :notes, on: :create

  belongs_to :team

  has_many :scans

  has_many :violations, through: :scans
  has_many :lap_times, through: :scans
  has_many :driver_registrations
  has_many :registrations, through: :driver_registrations
  has_many :sms_messages

  def self.as_csv(params={})
    collection = self
    if params[:created_at].present? && since = Time.parse(params[:created_at])
      collection = where(["created_at >= ?", since])
    end

    columns = %w{ last_name first_name email barcode has_rfid_reads? }
    CSV.generate do |csv|
      csv << columns
      collection.all.each do |item|
        row = columns.map { |c| item.send(c) }
        csv << row
      end
    end
  end

  def self.find_by_barcode(barcode)
    where(barcode: barcode).first
  end

  def unknown?
    self.barcode == "D#{self.class.barcode_offset}"
  end

  def known?
    not unknown?
  end

  def notifications_enabled?
    fcm_token.present?
  end

  def self.alex
    find_by(id: 13) || self.unknown
  end

  def self.nick
    find_by(id: 3) || self.unknown
  end

  def self.unknown
    unknown_barcode = "D#{self.barcode_offset}"

    unknown = self.where(barcode: unknown_barcode).first
    if unknown.present?
      unknown
    else
      create(barcode: unknown_barcode,
             first_name: "Driver",
             last_name: "Unknown",
             password: "password",
             password_confirmation: "password",
             email: "unknowndriver@americanenduranceracing.com",
             emergency_contact_name: "Nick Hance",
             emergency_contact_phone: "215-804-9408",
             cell_phone: "610-360-5238",
             shirt_size: "L")
    end
  end

  def self.autocomplete(name)
    return [] unless name.length >= 3

    drivers_arel = Driver.arel_table
    query = "#{name}%"

    where(drivers_arel[:first_name].matches(query).
          or(drivers_arel[:last_name].matches(query)).
          or(drivers_arel[:email].matches(query)))
  end

  def has_rfid_reads?
    rfid_reads_count > 0
  end

  def details
    self[:details] ||= {}
  end

  def approved?
    approved_at.present? && approved_at < Time.now
  end

  def experience
    details["experience"] ||= {}
  end

  def lifetime_lap_count
    lap_count_adjustment + lap_times.count
  end

  def rfid_reads_count
    RfidRead.for_driver_ids([self.id]).count
  end

  def autocomplete_json
    { label: "#{full_name} <#{email}>", value: id }
  end

  def full_name
    "#{self.first_name} #{self.last_name}"
  end
  alias :driver_name :full_name

  def mailchimp_csv
    [last_name, first_name, email].to_csv
  end

  def to_s
    full_name
  end

  def confirmation_required?
    # Rails.env.production?
    # Let's not have complaints about this until it's a problem
    false
  end

  def enable_extra_validation!
    @extra_validation = true
  end

  def require_extra_validation?
    @extra_validation || self.new_record?
  end

  def valid_with_extra_validation?
    enable_extra_validation!
    valid?
  end

  def name
    "[#{barcode}] #{first_name} #{last_name}"
  end

  def currently_driving
    if Event.current
      # Returns a list of cars this driver should be in during current event
      registration_ids = Event.current.registration_ids
      self.registrations.where(id: registration_ids).map(&:car)
    end
  end

  rails_admin do
    field :first_name do
      searchable true
    end

    field :last_name do
      searchable true
    end

    field :barcode

    field :email

    field :team

    include_all_fields

    show do
      include_all_fields
    end

    list do
      filters [:name, :email, :barcode, :created_at]

      field :name do
        searchable [:first_name, :last_name]
      end
      field :email do
        pretty_value do
          "<a href='mailto:#{value}?subject=Hi #{bindings[:object].full_name}' title='#{bindings[:object].full_name}'>#{value}</a>".html_safe
        end
      end
      field :team
      field :approved_at
      field :barcode

      exclude_fields :id, :updated_at
    end

  end
end
