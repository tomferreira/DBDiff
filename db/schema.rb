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

ActiveRecord::Schema.define(:version => 20140123173839) do

  create_table "comparisons", :force => true do |t|
    t.integer  "verification_from_id"
    t.integer  "verification_to_id"
    t.integer  "result"
    t.text     "structures_diff"
    t.text     "tables_diff"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  add_index "comparisons", ["verification_from_id"], :name => "index_comparisons_on_verification_from_id"
  add_index "comparisons", ["verification_to_id"], :name => "index_comparisons_on_verification_to_id"

  create_table "structures", :force => true do |t|
    t.string   "dump_filename"
    t.string   "schema"
    t.integer  "verification_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "structures", ["verification_id"], :name => "index_structures_on_verification_id"

  create_table "table_data_versions", :force => true do |t|
    t.string   "table"
    t.text     "data"
    t.integer  "verification_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "table_data_versions", ["verification_id"], :name => "index_table_data_versions_on_verification_id"

  create_table "users", :force => true do |t|
    t.string   "login",               :default => "", :null => false
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",       :default => 0,  :null => false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
  end

  add_index "users", ["login"], :name => "index_users_on_login", :unique => true

  create_table "verifications", :force => true do |t|
    t.string   "database"
    t.datetime "date"
    t.integer  "duration"
    t.boolean  "result"
    t.text     "error_message"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

end
