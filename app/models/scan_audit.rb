# create_table :scan_audits, force: :cascade do |t|
#   t.string   :response_code, limit: 255
#   t.string   :barcode,       limit: 255
#   t.string   :message,       limit: 255
#   t.string   :pit,           limit: 255
#   t.datetime :created_at
#   t.datetime :updated_at
# end

class ScanAudit < ActiveRecord::Base

  rails_admin do
    list do
      exclude_fields :id, :updated_at
    end
  end
end
