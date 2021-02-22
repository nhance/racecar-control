# create_table :violations, force: :cascade do |t|
#   t.integer  :scan_id,    limit: 4
#   t.text     :comment,    limit: 65535
#   t.datetime :created_at
#   t.datetime :updated_at
#   t.integer  :team_id,    limit: 4
# end

class Violation < ActiveRecord::Base
  belongs_to :scan, :inverse_of => :violations
  belongs_to :team#, optional: true # Rails 5
  has_one :driver, through: :scan

  def name
    "Violation: #{comment}"
  end

  rails_admin do
    list do
      field :scan
      field :comment
      field :created_at
    end
  end
end
