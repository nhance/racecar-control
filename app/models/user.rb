# create_table :users, force: :cascade do |t|
#   t.string   :email,                  limit: 255, default: "", null: false
#   t.string   :encrypted_password,     limit: 255, default: "", null: false
#   t.string   :reset_password_token,   limit: 255
#   t.datetime :reset_password_sent_at
#   t.datetime :remember_created_at
#   t.integer  :sign_in_count,          limit: 4,   default: 0,  null: false
#   t.datetime :current_sign_in_at
#   t.datetime :last_sign_in_at
#   t.string   :current_sign_in_ip,     limit: 255
#   t.string   :last_sign_in_ip,        limit: 255
#   t.datetime :created_at
#   t.datetime :updated_at
# end
#
# add_index :users, [:email], name: :index_users_on_email, unique: true, using: :btree
# add_index :users, [:reset_password_token], name: :index_users_on_reset_password_token, unique: true, using: :btree

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :registerable, :confirmable, :lockable, :timeoutable and :omniauthable
  # :trackable, :validatable
  devise :database_authenticatable, :recoverable, :rememberable

  def admin?
    true # All users have access to the admin area. This way we can create new accounts
  end
end
