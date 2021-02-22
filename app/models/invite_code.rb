# create_table :invite_codes, force: :cascade do |t|
#   t.string  :code,                     limit: 255
#   t.text    :description,              limit: 65535
#   t.integer :discount_amount_in_cents, limit: 4
#   t.integer :event_id,                 limit: 4
#   t.date    :expires_at
# end

class InviteCode < ActiveRecord::Base
  belongs_to :event, required: false

  validates_uniqueness_of :code

  def valid_for_registration?(registration)
    valid = true

    valid = false if event_id.present? && event_id != registration.event_id
    valid = false if expires_at.present? && Time.now > self.expires_at

    valid
  end

  rails_admin do
    field :code do
      searchable true
    end
    field :description
    field :discount_amount_in_cents

    show do
      field :code
      field :discount_amount_in_cents
      field :description
    end

    list do
      filters [:code]

      field :code
      field :discount_amount_in_cents
      field :description
      exclude_fields :id, :updated_at
    end

  end
end
