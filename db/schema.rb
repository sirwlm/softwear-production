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

ActiveRecord::Schema.define(version: 20141020161948) do

  create_table "api_settings", force: true do |t|
    t.string   "endpoint"
    t.string   "auth_token"
    t.string   "homepage"
    t.string   "slug"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "api_settings", ["slug"], name: "index_api_settings_on_slug", unique: true, using: :btree

  create_table "friendly_id_slugs", force: true do |t|
    t.string   "slug",                      null: false
    t.integer  "sluggable_id",              null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope"
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, using: :btree
  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", using: :btree
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree

  create_table "imprints", force: true do |t|
    t.integer  "softwear_crm_id"
    t.integer  "job_id"
    t.datetime "scheduled_at"
    t.datetime "estimated_end_at"
    t.decimal  "estimated_time",   precision: 10, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "machine_id"
  end

  add_index "imprints", ["machine_id"], name: "index_imprints_on_machine_id", using: :btree

  create_table "jobs", force: true do |t|
    t.integer  "softwear_crm_id"
    t.integer  "order_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "machines", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "orders", force: true do |t|
    t.integer  "softwear_crm_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "trains", force: true do |t|
    t.string   "kind"
    t.integer  "trainable_id"
    t.string   "trainable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
