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

ActiveRecord::Schema.define(:version => 4) do

  create_table "photos", :force => true do |t|
    t.string   "filename"
    t.integer  "user_id"
    t.string   "owner_token"
    t.datetime "created_at"
  end

  add_index "photos", ["owner_token"], :name => "index_photos_on_owner_token"
  add_index "photos", ["user_id"], :name => "index_photos_on_user_id"

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
    t.boolean "vote"
  end

  add_index "votes", ["user_id"], :name => "index_votes_on_user_id"
  add_index "votes", ["photo_id"], :name => "index_votes_on_photo_id"

end
