# create_table :registrations, force: :cascade do |t|
#   t.integer  :event_id,                    limit: 4
#   t.integer  :car_id,                      limit: 4
#   t.datetime :created_at
#   t.datetime :updated_at
#   t.string   :car_number,                  limit: 255
#   t.string   :car_class,                   limit: 255
#   t.integer  :price_in_cents,              limit: 4
#   t.integer  :registered_by_id,            limit: 4
#   t.string   :state,                       limit: 255
#   t.string   :transponder_number,          limit: 25
#   t.boolean  :transponder_rental,                      default: false
#   t.boolean  :accepts_supplemental_charge,             default: false
#   t.string   :invite_code_code,            limit: 255
#   t.boolean  :verified,                                default: false
# end
#
# add_index :registrations, [:event_id, :car_id], name: :index_registrations_on_event_id_and_car_id_and_driver_id, using: :btree

class Registration < ActiveRecord::Base
  include AASM

  TRANSPONDER_RENTAL_PRICE = 50_00

  MINIMUM_PAYMENT_IN_CENTS = 360_00
  MINIMUM_DRIVER_REGISTRATIONS = 2

  COMPLETION_REQUIREMENTS = ["Your balance must be paid in full",
                             "You must have at least #{MINIMUM_DRIVER_REGISTRATIONS} drivers registered"]

  has_paper_trail

  default_scope { where("registrations.state != 'interested'") }

  belongs_to :car
  belongs_to :event

  belongs_to :registered_by, class_name: 'Driver'

  has_one :team, through: :car

  has_many :scans, dependent: :destroy
  has_many :payments, dependent: :nullify
  has_many :driver_registrations, dependent: :destroy
  has_many :item_reservations, dependent: :destroy

  has_many :drivers, through: :driver_registrations
  has_many :violations, through: :scans

  has_many :lap_times, through: :scans

  validates :car, :event, :price_in_cents, presence: true
  validate :event_is_in_future, on: :create
  validate :car_is_in_season

  validates_uniqueness_of :car_id, scope: :event_id

  before_validation :assign_default_price, on: :create
  before_validation :assign_rental_transponder

  validate :invite_code_can_be_added

  scope :order_by_car_number, -> { joins(:car).order('cars.number asc') }
  scope :expected_at_event,   -> { where(state: ['pending', 'ready']) }
  scope :ready,   -> { where(state: 'ready') }
  scope :future,              -> { joins(:event).where(['events.start_date > ?', Date.today]) }
  scope :not_ready,           -> { where(['state != ?', 'ready']) } # Warning: you must call `unscoped` for this to work

  aasm column: :state do
    state :interested, initial: true
    state :pending
    state :ready
    state :cancelled

    event :process do
      transitions from: :interested, to: :pending, unless: :minimum_payment_due?
      transitions from: :pending, to: :ready, if: :complete?

      # These items must exist so we can call process every save
      transitions from: :interested, to: :interested
      transitions from: :pending, to: :pending
      transitions from: :ready, to: :ready
      transitions from: :cancelled, to: :cancelled
    end
  end

  rails_admin do
    show do
      field :car do
        inverse_of :registrations # For linking in display (https://github.com/sferik/rails_admin/wiki/Associations-basics#inverse_of-avoiding-edit-association-spaghetti-issues)
      end
      field :registered_by do
        pretty_value do
          "<a href='mailto:#{value.email}?subject=Hi #{value.name}' title='#{value.name}'>#{value.email}</a>".html_safe
        end
      end

      include_all_fields

      field :payments do
        pretty_value do
          v = bindings[:view]
          value.map do |payment|
            v.link_to("[#{payment.created_at.strftime("%m/%d")}] $#{payment.amount} by #{payment.driver}", "/admin/payment/#{payment.id}")
          end.to_sentence.html_safe
        end
      end
    end

    export do
      field :car, :string do
        read_only true
        label "Car Number"

        export_value do
          value.number
        end
      end

      field :team, :string do
        read_only true

        export_value do
          value.name
        end
      end
    end

    list do
      filters [:event_id, :state, :transponder_rental, :accepts_supplemental_charge, :created_at]

      field :team
      field :car do
        inverse_of :registrations # For linking in display (https://github.com/sferik/rails_admin/wiki/Associations-basics#inverse_of-avoiding-edit-association-spaghetti-issues)
      end
      field :driver_count
      field :transponder
      field :transponder_rental
      field :amount_due
      field :registered_by do
        pretty_value do
          "<a href='mailto:#{value.email}?subject=Hi #{value.name}' title='#{value.name}'>#{value.email}</a>".html_safe
        end
      end
      field :state, :enum do
        enum do
          ['ready', 'pending', 'interested']
        end
      end
      field :accepts_supplemental_charge

      field :event_id, :enum do
        enum do
          Event.all.map { |e| [e.to_s, e.id] }
        end
      end

      field :created_at
    end
  end

  def self.by_car_number(car_number)
    joins(:car).where(cars: { season_id: Season.current.id, number: car_number }).first
  end

  def self.for_barcode(barcode)
    if decoded = Car.valid_barcode?(barcode)
      find_by(car_id: decoded.id)
    end
  end

  def to_s
    "#{car} at #{event}"
  end

  def attending_race?
    ['ready', 'pending'].include?(self.state.to_s)
  end

  def reservables
    self.event.reservable_items
  end

  def reserved?(reservable_item)
    reservation_number(reservable_item).present?
  end

  def reservation_number(reservable_item)
    @reservation_number ||= {}

    @reservation_number[reservable_item.id] ||= ItemReservation.where(registration_id: self.id, reservable_item: reservable_item.id).pluck(:item_number).first

    @reservation_number[reservable_item.id]
  end

  def invite_code
    if invite_code_code.present? and invite_code = InviteCode.where(code: invite_code_code).first
      invite_code
    end
  end

  def name
    # This method exists for rails_admin
    # Warning: does not show event detail!!
    if car.present?
      "##{car.number} #{team} (#{car.year} #{car.make})"
    else
      "Registration ##{id}"
    end
  end

  def car_name
    "#{team}"
  end

  def car_number
    car.number
  end

  def status
    state.to_s.capitalize
  end

  def complete?
    paid_in_full?
  end

  def minimum_drivers_registered?
    driver_count >= MINIMUM_DRIVER_REGISTRATIONS
  end

  def driver_count
    self.driver_registrations.count
  end

  def registered_driver_ids
    self.driver_registrations.pluck(:driver_id)
  end

  def minimum_payment_due?
    # This is complicated because we need to be able to offer a discount
    # and still have the minimum payment be due unless the discount is big enough
    # to make that requirement not matter.
    #
    # Please improve logic and remove this comment if you like.

    return false if my_price < MINIMUM_PAYMENT_IN_CENTS
    return false if discount >= MINIMUM_PAYMENT_IN_CENTS
    return false if amount_due(refresh: true) < MINIMUM_PAYMENT_IN_CENTS
    return false if amount_paid(refresh: true) >= MINIMUM_PAYMENT_IN_CENTS

    true
  end

  def paid_in_full?
    amount_due(refresh: true) <= 0
  end

  def discount
    if self.invite_code.present?
      invite_code.discount_amount_in_cents
    else
      0
    end
  end

  def my_price
    self.price_in_cents - discount
  end

  def admission_paid?
    amount_paid >= my_price
  end

  def payment_due?
    !paid_in_full?
  end

  def total_price
    total = my_price
    total += TRANSPONDER_RENTAL_PRICE if self.transponder_rental?
    total += self.item_reservations.sum(:item_price_in_cents)

    total
  end

  def amount_due(refresh: false)
    @amount_due = nil if refresh

    if @amount_due.nil?
      @amount_due = total_price - amount_paid(refresh: refresh)
    end

    @amount_due
  end

  def amount_due_dollars
    amount_due / 100
  end

  def amount_paid(refresh: false)
    @amount_paid = nil if refresh

    @amount_paid ||= self.payments.sum(:amount_paid_in_cents)
  end

  def registered_driver?(driver)
    self.driver_registrations.where(driver_id: driver.id).count > 0
  end

  def transponder
    if transponder_number.present?
      transponder_number
    elsif car.transponder_number.present?
      car.transponder_number
    end
  end

  def last_pit_out
    self.scans.out.order("created_at").last
  end

  def event_is_in_future
    errors.add(:event, "must be an upcoming event") if event.nil? or not (event.upcoming? or event.current?)
  end

  def car_is_in_season
    errors.add(:car, "is from an invalid season") if car.season_id != event.season_id or car.season_id.blank?
  end

  def assign_default_price
    self.price_in_cents ||= self.event.price_in_cents if self.event.present?
  end

  def assign_rental_transponder
    self.transponder_rental = true if must_rent_transponder?
  end

  def must_rent_transponder?
    self.car.transponder_number.blank?
  end

  def orbits_export_data
    [
      car_name,
      transponder,
      car.number,
      "#{registered_by.try(:full_name)}",
      car_class,
      car.car_type
    ]
  end

  def invite_code_can_be_added
    if invite_code && invite_code.valid_for_registration?(self)
      true
    else
      self.invite_code_code = nil
      true
    end
  end
end
