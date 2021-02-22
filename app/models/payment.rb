# create_table :payments, force: :cascade do |t|
#   t.integer  :driver_id,            limit: 4
#   t.integer  :registration_id,      limit: 4
#   t.integer  :amount_paid_in_cents, limit: 4
#   t.datetime :created_at
#   t.datetime :updated_at
#   t.string   :stripe_charge_id,     limit: 255
# end

class Payment < ActiveRecord::Base
  belongs_to :driver
  belongs_to :registration

  validate :amount_is_lte_amount_due, on: :create

  after_create :process_registration

  def amount
    amount_paid_in_cents / 100
  end

  def amount_is_lte_amount_due
    errors.add(:amount_paid_in_cents, "must be less than amount due") if amount_paid_in_cents > registration.amount_due
  end

  def process_registration
    registration.process!
  end
end
