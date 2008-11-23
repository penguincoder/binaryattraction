# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 9) do

  create_table "photo_favorites", :force => true do |t|
    t.integer "photo_id"
    t.integer "user_id"
  end

  add_index "photo_favorites", ["photo_id"], :name => "index_photo_favorites_on_photo_id"
  add_index "photo_favorites", ["user_id"], :name => "index_photo_favorites_on_user_id"

  create_table "photo_flags", :force => true do |t|
    t.integer "user_id"
    t.integer "photo_id"
    t.string  "session_id"
  end

  add_index "photo_flags", ["user_id"], :name => "index_photo_flags_on_user_id"
  add_index "photo_flags", ["photo_id"], :name => "index_photo_flags_on_photo_id"

  create_table "photos", :force => true do |t|
    t.string   "filename"
    t.string   "content_type"
    t.string   "email_hash"
    t.integer  "width"
    t.integer  "height"
    t.integer  "user_id"
    t.datetime "created_at"
    t.boolean  "approved",                       :default => false
    t.integer  "votes_count",                    :default => 0
    t.integer  "one_votes",                      :default => 0
    t.integer  "zero_votes",                     :default => 0
    t.float    "oneness"
    t.integer  "photo_flags_count",              :default => 0
    t.integer  "facebook_id",       :limit => 8
  end

  add_index "photos", ["email_hash"], :name => "index_photos_on_email_hash"
  add_index "photos", ["user_id"], :name => "index_photos_on_user_id"
  add_index "photos", ["votes_count"], :name => "index_photos_on_votes_count"
  add_index "photos", ["oneness"], :name => "index_photos_on_oneness"
  add_index "photos", ["approved"], :name => "index_photos_on_approved"
  add_index "photos", ["facebook_id"], :name => "index_photos_on_facebook_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"

  create_table "users", :force => true do |t|
    t.string   "user_name",     :limit => 32
    t.string   "auth_token"
    t.boolean  "administrator"
    t.datetime "created_at"
    t.integer  "facebook_id",   :limit => 8
  end

  add_index "users", ["user_name"], :name => "index_users_on_user_name"
  add_index "users", ["facebook_id"], :name => "index_users_on_facebook_id"

  create_table "votes", :force => true do |t|
    t.integer "photo_id"
    t.integer "user_id"
    t.string  "session_id"
    t.boolean "vote"
  end

  add_index "votes", ["photo_id"], :name => "index_votes_on_photo_id"
  add_index "votes", ["user_id"], :name => "index_votes_on_user_id"
  add_index "votes", ["session_id"], :name => "index_votes_on_session_id"

end
