# create_table :driver_registrations, force: :cascade do |t|
#   t.integer :driver_id,       limit: 4
#   t.integer :registration_id, limit: 4
#   t.string  :state,           limit: 255, default: :new
# end

class DriverRegistration < ActiveRecord::Base
  include AASM

  belongs_to :driver
  belongs_to :registration

  validates_uniqueness_of :driver_id, scope: :registration_id

  comma do
    id
    driver :first_name => 'First Name',
           :last_name => 'Last Name',
           :email     => 'Email Address',
           :cell_phone => 'Cell Phone',
           :city      => 'City',
           :state     => 'State',
           :approved_at => 'Driver Approved time',
           :barcode   => 'Driver barcode',
           :id => 'driver id',
           :shirt_size => 'shirt size',
           :lifetime_lap_count => 'Lap count',
           :has_rfid_reads? => 'RFID seen?',
           :created_at => 'Driver Signup at'

    team :name => "Team Name"

    registration :state => 'Registration status'

    car :number => 'Car number',
        :make => 'Car Make',
        :model => 'car model',
        :barcode => 'car barcode',
        :id => 'car id'

  end

  aasm column: :state do
    state :new, initial: true
    state :checked_in

    event :check_in do
      transitions from: :new, to: :checked_in
    end
  end

  after_create :reprocess_registration
  after_create :add_driver_to_team

  def car
    registration.try(:car) || Car.new
  end

  def to_s
    "#{driver} in #{registration}"
  end

  def team
    driver.try(:team) || Team.new
  end

  def event
    registration.try(:event) || Event.new
  end

  private
  def reprocess_registration
    registration.process!
  end

  def add_driver_to_team
    # This was disabled because drivers were adding everyone to their team.
    #driver.update_attribute(:team, registration.team)
  end
end
