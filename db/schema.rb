# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171003202040) do

  create_table "cars", force: :cascade do |t|
    t.string   "barcode",              limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "make",                 limit: 255
    t.string   "model",                limit: 255
    t.integer  "captain_id",           limit: 4
    t.string   "passcode",             limit: 255
    t.integer  "year",                 limit: 4
    t.integer  "team_id",              limit: 4
    t.string   "color",                limit: 25
    t.string   "transponder_number",   limit: 25
    t.integer  "season_id",            limit: 4
    t.string   "number",               limit: 5
    t.integer  "tech_inspection_year", limit: 4
  end

  add_index "cars", ["barcode"], name: "index_cars_on_barcode", using: :btree

  create_table "driver_registrations", force: :cascade do |t|
    t.integer "driver_id",       limit: 4
    t.integer "registration_id", limit: 4
    t.string  "state",           limit: 255, default: "new"
  end

  create_table "drivers", force: :cascade do |t|
    t.string   "barcode",                 limit: 255
    t.string   "first_name",              limit: 255
    t.string   "last_name",               limit: 255
    t.string   "email",                   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "cell_phone",              limit: 255
    t.string   "encrypted_password",      limit: 255,   default: "",   null: false
    t.string   "reset_password_token",    limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",           limit: 4,     default: 0,    null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",      limit: 255
    t.string   "last_sign_in_ip",         limit: 255
    t.string   "confirmation_token",      limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",       limit: 255
    t.string   "street_address",          limit: 255
    t.string   "city",                    limit: 255
    t.string   "state",                   limit: 255
    t.string   "zip_code",                limit: 255
    t.string   "emergency_contact_name",  limit: 255
    t.string   "emergency_contact_phone", limit: 255
    t.text     "details",                 limit: 65535
    t.integer  "team_id",                 limit: 4
    t.string   "referred_by",             limit: 255
    t.boolean  "allow_sms",                             default: true
    t.string   "shirt_size",              limit: 255
    t.datetime "approved_at"
    t.string   "fcm_token",               limit: 255
    t.integer  "lap_count_adjustment",    limit: 4,     default: 0
    t.text     "notes",                   limit: 65535
    t.text     "admin_notes",             limit: 65535
  end

  add_index "drivers", ["barcode"], name: "index_drivers_on_barcode", using: :btree
  add_index "drivers", ["email"], name: "index_drivers_on_email", unique: true, using: :btree
  add_index "drivers", ["reset_password_token"], name: "index_drivers_on_reset_password_token", unique: true, using: :btree

  create_table "events", force: :cascade do |t|
    t.string   "track",               limit: 255
    t.date     "start_date"
    t.date     "stop_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "abbr",                limit: 255
    t.float    "track_length",        limit: 24
    t.string   "supplemental_charge", limit: 255
    t.text     "promo_content",       limit: 65535
    t.integer  "season_id",           limit: 4
    t.integer  "capacity",            limit: 4,     default: 50
    t.integer  "supplemental_limit",  limit: 4,     default: 50
    t.integer  "price_in_cents",      limit: 4
  end

  add_index "events", ["abbr"], name: "index_events_on_abbr", using: :btree

  create_table "fcm_tokens", force: :cascade do |t|
    t.integer  "driver_id",  limit: 4
    t.string   "token",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string   "slug",           limit: 255, null: false
    t.integer  "sluggable_id",   limit: 4,   null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope",          limit: 255
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, using: :btree
  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", using: :btree
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree

  create_table "invite_codes", force: :cascade do |t|
    t.string  "code",                     limit: 255
    t.text    "description",              limit: 65535
    t.integer "discount_amount_in_cents", limit: 4
    t.integer "event_id",                 limit: 4
    t.date    "expires_at"
  end

  create_table "item_reservations", force: :cascade do |t|
    t.integer "reservable_item_id",  limit: 4
    t.integer "registration_id",     limit: 4
    t.string  "item_number",         limit: 255
    t.integer "item_price_in_cents", limit: 4
  end

  create_table "lap_times", force: :cascade do |t|
    t.integer  "scan_id",      limit: 4
    t.decimal  "lap_time",                 precision: 8, scale: 3
    t.boolean  "qualifying",                                       default: false
    t.string   "track_status", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position",     limit: 4
    t.integer  "lap_number",   limit: 4
    t.integer  "event_id",     limit: 4
    t.string   "car_number",   limit: 255
  end

  add_index "lap_times", ["created_at"], name: "index_lap_times_on_created_at", using: :btree
  add_index "lap_times", ["event_id"], name: "index_lap_times_on_event_id", using: :btree

  create_table "oauth_access_grants", force: :cascade do |t|
    t.integer  "resource_owner_id", limit: 4,     null: false
    t.integer  "application_id",    limit: 4,     null: false
    t.string   "token",             limit: 255,   null: false
    t.integer  "expires_in",        limit: 4,     null: false
    t.text     "redirect_uri",      limit: 65535, null: false
    t.datetime "created_at",                      null: false
    t.datetime "revoked_at"
    t.string   "scopes",            limit: 255
  end

  add_index "oauth_access_grants", ["application_id"], name: "fk_rails_b4b53e07b8", using: :btree
  add_index "oauth_access_grants", ["token"], name: "index_oauth_access_grants_on_token", unique: true, using: :btree

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.integer  "resource_owner_id",      limit: 4
    t.integer  "application_id",         limit: 4
    t.string   "token",                  limit: 255,              null: false
    t.string   "refresh_token",          limit: 255
    t.integer  "expires_in",             limit: 4
    t.datetime "revoked_at"
    t.datetime "created_at",                                      null: false
    t.string   "scopes",                 limit: 255
    t.string   "previous_refresh_token", limit: 255, default: "", null: false
  end

  add_index "oauth_access_tokens", ["application_id"], name: "fk_rails_732cb83ab7", using: :btree
  add_index "oauth_access_tokens", ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true, using: :btree
  add_index "oauth_access_tokens", ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id", using: :btree
  add_index "oauth_access_tokens", ["token"], name: "index_oauth_access_tokens_on_token", unique: true, using: :btree

  create_table "oauth_applications", force: :cascade do |t|
    t.string   "name",         limit: 255,                null: false
    t.string   "uid",          limit: 255,                null: false
    t.string   "secret",       limit: 255,                null: false
    t.text     "redirect_uri", limit: 65535,              null: false
    t.string   "scopes",       limit: 255,   default: "", null: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  add_index "oauth_applications", ["uid"], name: "index_oauth_applications_on_uid", unique: true, using: :btree

  create_table "payments", force: :cascade do |t|
    t.integer  "driver_id",            limit: 4
    t.integer  "registration_id",      limit: 4
    t.integer  "amount_paid_in_cents", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "stripe_charge_id",     limit: 255
  end

  create_table "points_adjustments", force: :cascade do |t|
    t.integer  "race_id",         limit: 4
    t.integer  "registration_id", limit: 4
    t.integer  "points",          limit: 4
    t.string   "reason",          limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "races", force: :cascade do |t|
    t.integer  "event_id",   limit: 4
    t.string   "name",       limit: 255
    t.datetime "start_time"
    t.datetime "end_time"
    t.boolean  "qualifying",             default: false
  end

  add_index "races", ["event_id"], name: "index_races_on_event_id", using: :btree

  create_table "registrations", force: :cascade do |t|
    t.integer  "event_id",                    limit: 4
    t.integer  "car_id",                      limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "car_number",                  limit: 255
    t.string   "car_class",                   limit: 255
    t.integer  "price_in_cents",              limit: 4
    t.integer  "registered_by_id",            limit: 4
    t.string   "state",                       limit: 255
    t.string   "transponder_number",          limit: 25
    t.boolean  "transponder_rental",                      default: false
    t.boolean  "accepts_supplemental_charge",             default: false
    t.string   "invite_code_code",            limit: 255
    t.boolean  "verified",                                default: false
  end

  add_index "registrations", ["event_id", "car_id"], name: "index_registrations_on_event_id_and_car_id_and_driver_id", using: :btree

  create_table "reservable_items", force: :cascade do |t|
    t.integer  "event_id",            limit: 4
    t.string   "name",                limit: 255
    t.string   "image_file_name",     limit: 255
    t.string   "image_content_type",  limit: 255
    t.integer  "image_file_size",     limit: 4
    t.datetime "image_updated_at"
    t.text     "items_available",     limit: 65535
    t.integer  "uses_per_item",       limit: 4,     default: 1
    t.boolean  "visible_to_drivers",                default: false
    t.integer  "item_price_in_cents", limit: 4,     default: 0
    t.text     "description",         limit: 65535
  end

  create_table "results", force: :cascade do |t|
    t.integer  "race_id",         limit: 4
    t.integer  "registration_id", limit: 4
    t.string   "car_class",       limit: 255
    t.integer  "position",        limit: 4
    t.integer  "laps",            limit: 4
    t.integer  "points",          limit: 4
    t.datetime "last_lap_at"
    t.integer  "lap_time_id",     limit: 4
  end

  add_index "results", ["race_id"], name: "index_results_on_race_id", using: :btree
  add_index "results", ["registration_id"], name: "index_results_on_registration_id", using: :btree

  create_table "rfid_readers", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.string   "mac_address",     limit: 255
    t.string   "role",            limit: 255
    t.string   "last_ip_address", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rfid_reads", force: :cascade do |t|
    t.integer  "rfid_reader_id",       limit: 4
    t.string   "reader_role",          limit: 255
    t.integer  "first_seen_timestamp", limit: 8
    t.string   "antenna_port",         limit: 255
    t.string   "epc",                  limit: 255
    t.string   "peak_rssi",            limit: 255
    t.string   "tid",                  limit: 255
    t.text     "raw_request",          limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "scan_id",              limit: 4
  end

  add_index "rfid_reads", ["first_seen_timestamp"], name: "index_rfid_reads_on_first_seen_timestamp", using: :btree

  create_table "rfid_tests", force: :cascade do |t|
    t.text "params",           limit: 65535
    t.text "expected_to_read", limit: 65535
  end

  create_table "scan_audits", force: :cascade do |t|
    t.string   "response_code", limit: 255
    t.string   "barcode",       limit: 255
    t.string   "message",       limit: 255
    t.string   "pit",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "scans", force: :cascade do |t|
    t.string   "pit",              limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "stop_at"
    t.integer  "registration_id",  limit: 4
    t.integer  "driver_id",        limit: 4
    t.boolean  "short_stop",                                           default: false
    t.datetime "processed_at"
    t.decimal  "fastest_lap_time",             precision: 8, scale: 3
    t.decimal  "average_lap_time",             precision: 8, scale: 3
    t.integer  "total_laps",       limit: 4
    t.string   "state",            limit: 255
    t.decimal  "variance",                     precision: 8, scale: 3
    t.decimal  "std_dev",                      precision: 8, scale: 3
    t.decimal  "longest_lap",                  precision: 8, scale: 3
    t.decimal  "stint_length",                 precision: 8, scale: 3
    t.integer  "position_change",  limit: 4
    t.integer  "rfid_read_id",     limit: 4
    t.integer  "second_driver_id", limit: 4
    t.integer  "in_scan_id",       limit: 4
  end

  add_index "scans", ["created_at"], name: "index_scans_on_created_at", using: :btree

  create_table "seasons", force: :cascade do |t|
    t.integer "event_price_in_cents",  limit: 4
    t.date    "start_date"
    t.integer "points_eligible_races", limit: 4
  end

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 255,   null: false
    t.text     "data",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "sms_messages", force: :cascade do |t|
    t.string   "number",        limit: 255
    t.string   "message",       limit: 255
    t.datetime "sent_at"
    t.integer  "resource_id",   limit: 4
    t.string   "resource_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "driver_id",     limit: 4
    t.datetime "read_at"
  end

  add_index "sms_messages", ["driver_id", "read_at"], name: "index_sms_messages_on_driver_id_and_read_at", using: :btree

  create_table "teams", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "passcode",   limit: 255
    t.integer  "captain_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "urls", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.string   "url",              limit: 255
    t.integer  "attached_to_id",   limit: 4
    t.string   "attached_to_type", limit: 255
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "urls", ["attached_to_type", "attached_to_id"], name: "index_urls_on_attached_to_type_and_attached_to_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",      limit: 255,   null: false
    t.integer  "item_id",        limit: 4,     null: false
    t.string   "event",          limit: 255,   null: false
    t.string   "whodunnit",      limit: 255
    t.text     "object",         limit: 65535
    t.datetime "created_at"
    t.text     "object_changes", limit: 65535
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  create_table "violations", force: :cascade do |t|
    t.integer  "scan_id",    limit: 4
    t.text     "comment",    limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "team_id",    limit: 4
  end

  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "races", "events"
  add_foreign_key "results", "races"
  add_foreign_key "results", "registrations"
end
