# create_table :urls, force: :cascade do |t|
#   t.string   :name,             limit: 255
#   t.string   :url,              limit: 255
#   t.integer  :attached_to_id,   limit: 4
#   t.string   :attached_to_type, limit: 255
#   t.datetime :created_at,                   null: false
#   t.datetime :updated_at,                   null: false
# end
#
# add_index :urls, [:attached_to_type, :attached_to_id], name: :index_urls_on_attached_to_type_and_attached_to_id, using: :btree

class Url < ActiveRecord::Base
  belongs_to :attached_to, polymorphic: true
end
