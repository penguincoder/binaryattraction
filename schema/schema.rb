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

ActiveRecord::Schema.define(:version => 5) do

  create_table "photo_favorites", :force => true do |t|
    t.integer "photo_id"
    t.integer "user_id"
  end

  add_index "photo_favorites", ["user_id"], :name => "index_photo_favorites_on_user_id"
  add_index "photo_favorites", ["photo_id"], :name => "index_photo_favorites_on_photo_id"

  create_table "photos", :force => true do |t|
    t.string   "filename"
    t.string   "content_type"
    t.string   "email_hash"
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at"
    t.boolean  "approved"
  end

  add_index "photos", ["email_hash"], :name => "index_photos_on_email_hash"

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
  end

  add_index "users", ["user_name"], :name => "index_users_on_user_name"

  create_table "votes", :force => true do |t|
    t.integer "photo_id"
    t.integer "user_id"
    t.string  "session_id"
    t.boolean "vote"
  end

  add_index "votes", ["session_id"], :name => "index_votes_on_session_id"
  add_index "votes", ["user_id"], :name => "index_votes_on_user_id"
  add_index "votes", ["photo_id"], :name => "index_votes_on_photo_id"

end
