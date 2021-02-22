# create_table :reservable_items, force: :cascade do |t|
#   t.integer  :event_id,            limit: 4
#   t.string   :name,                limit: 255
#   t.string   :image_file_name,     limit: 255
#   t.string   :image_content_type,  limit: 255
#   t.integer  :image_file_size,     limit: 4
#   t.datetime :image_updated_at
#   t.text     :items_available,     limit: 65535
#   t.integer  :uses_per_item,       limit: 4,     default: 1
#   t.boolean  :visible_to_drivers,                default: false
#   t.integer  :item_price_in_cents, limit: 4,     default: 0
#   t.text     :description,         limit: 65535
# end

class ReservableItem < ActiveRecord::Base
  belongs_to :event
  has_attached_file :image

  has_many :item_reservations, dependent: :destroy

  validates :name, presence: true
  validates :items_available, presence: true
  validates_attachment :image, content_type: { content_type: ["image/jpg", "image/jpeg", "image/png", "image/gif"] }

  scope :visible, -> { where(visible_to_drivers: true) }

  rails_admin do
    field :event
    field :name
    field :image
    field :items_available do
      help "Required. Enter items one per line or enter a single number to how many spaces are available"
    end
    field :uses_per_item
    field :visible_to_drivers
    field :item_price_in_cents
    field :description

    show do
      include_all_fields
    end

    list do
      include_all_fields
    end
  end

  def spot_numbers
    spots = items_available.split("\n").map(&:chomp)

    if spots.count == 1 && spots.first.to_i > 0
      ("1"..spots.first)
    else
      spots
    end
  end

  def reservations
    reservations = {}

    spot_numbers.each do |spot_number|
      reservations[spot_number] = []
    end

    self.item_reservations.joins(:registration).each do |item_reservation|
      reservations[item_reservation.item_number] << item_reservation.registration
    end

    reservations
  end
end
