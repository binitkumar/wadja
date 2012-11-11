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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121111183258) do

  create_table "connections", :force => true do |t|
    t.integer  "user_id"
    t.string   "network"
    t.string   "token"
    t.string   "secret"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "countries", :force => true do |t|
    t.string   "iso"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "notifications", :force => true do |t|
    t.integer  "user_id"
    t.integer  "contact_id"
    t.text     "message"
    t.string   "request"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "points", :force => true do |t|
    t.integer  "user_id"
    t.integer  "total"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "requests_mades", :force => true do |t|
    t.integer  "user_id"
    t.integer  "requested_user_id"
    t.integer  "type_id"
    t.integer  "status_id"
    t.datetime "date_sent"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "statuses", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.integer  "country_id"
    t.string   "username"
    t.string   "name"
    t.string   "email"
    t.boolean  "email_verified"
    t.date     "birth_date"
    t.string   "password"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.string   "photo_url"
    t.string   "gender"
    t.integer  "connection_id"
    t.boolean  "online"
    t.string   "password_salt"
    t.string   "password_hash"
    t.string   "authentication_token"
  end

end
