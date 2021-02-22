# create_table :item_reservations, force: :cascade do |t|
#   t.integer :reservable_item_id,  limit: 4
#   t.integer :registration_id,     limit: 4
#   t.string  :item_number,         limit: 255
#   t.integer :item_price_in_cents, limit: 4
# end

class ItemReservation < ActiveRecord::Base
  belongs_to :reservable_item, inverse_of: :item_reservations
  belongs_to :registration

  validates_associated :reservable_item
  validate :item_number_is_in_valid_range
  validate :enforce_reservation_limits, on: :create
  validates_uniqueness_of :registration_id, scope: :reservable_item_id

  delegate :name, to: :reservable_item

  before_create :assign_price

  rails_admin do
    field :reservable_item_id, :enum do
      enum do
        ReservableItem.all.collect { |ri| ["#{ri.name} (#{ri.event})", ri.id] }
      end
    end

    list do
      filters [:reservable_item_id]

      field :registration
      field :item_number
      field :item_price_in_cents
    end

    export do
      field :registration
      field :item_number
    end
  end

  def item_number_is_in_valid_range
    if item_number.blank? or
       !reservable_item.spot_numbers.include?(item_number)

      errors.add(:item_number, "is outside of a valid range")
    end
  end

  def enforce_reservation_limits
    other_entries = self.class.where(reservable_item: reservable_item, item_number: item_number).count

    if other_entries >= reservable_item.uses_per_item
      errors.add(:item_number, "has reached its reservation limit")
    end
  end

  def assign_price
    self.item_price_in_cents ||= reservable_item.item_price_in_cents
  end
end
