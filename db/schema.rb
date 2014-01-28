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

ActiveRecord::Schema.define(version: 20140128091121) do

  create_table "ad_infos", force: true do |t|
    t.text     "urlNormalized"
    t.text     "externId"
    t.string   "externSource"
    t.datetime "lastCheckAt"
    t.integer  "numFailedChecks"
    t.datetime "firstFailedCheck"
    t.string   "infoState",        default: "basic"
    t.string   "title"
    t.text     "description"
    t.decimal  "price"
    t.text     "imageUrl"
    t.string   "priceNotice"
    t.string   "priceType"
    t.string   "shortAddress"
    t.text     "mapurl"
    t.string   "ownership"
    t.text     "shortInfoHtml"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "changes", force: true do |t|
    t.integer  "search_info_id"
    t.integer  "ad_info_id"
    t.string   "changeType"
    t.string   "changeSubtype"
    t.string   "data"
    t.text     "dataBefore"
    t.text     "dataAfter"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notifications", force: true do |t|
    t.integer  "search_info_id"
    t.integer  "ad_info_id"
    t.integer  "request_id"
    t.string   "notificationType"
    t.string   "notificationSubtype"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "requests", force: true do |t|
    t.string   "title"
    t.text     "url"
    t.boolean  "processed",             default: false
    t.integer  "numFailedAttempts",     default: 0
    t.datetime "firstFailedAttempt"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "token"
    t.string   "tarrif",                default: "T1_none"
    t.string   "state",                 default: "created"
    t.string   "varsymbol"
    t.integer  "numnotificationrounds", default: 0
  end

  add_index "requests", ["url", "email"], name: "index_requests_on_url_and_email", unique: true, using: :btree

  create_table "requests_search_infos", force: true do |t|
    t.integer "search_info_id"
    t.integer "request_id"
  end

  create_table "search_info_ads_relations", force: true do |t|
    t.integer "search_info_id"
    t.integer "ad_info_id"
  end

  create_table "search_infos", force: true do |t|
    t.text     "urlNormalized"
    t.string   "usage",            default: "user"
    t.text     "externId"
    t.string   "externSource"
    t.datetime "lastCheckAt"
    t.integer  "numFailedChecks"
    t.datetime "firstFailedCheck"
    t.integer  "resultsCount"
    t.string   "lastExternId"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
