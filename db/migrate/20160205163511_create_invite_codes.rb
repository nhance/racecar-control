class CreateInviteCodes < ActiveRecord::Migration
  def change
    create_table :invite_codes do |t|
      t.string :code
      t.text    :description
      t.integer :discount_amount_in_cents
      t.integer :event_id
      t.date :expires_at
    end

    add_column :registrations, :invite_code_code, :string
  end
end
