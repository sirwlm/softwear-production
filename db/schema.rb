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

ActiveRecord::Schema.define(version: 20150923181317) do

  create_table "activities", force: :cascade do |t|
    t.integer  "trackable_id",   limit: 4
    t.string   "trackable_type", limit: 255
    t.integer  "owner_id",       limit: 4
    t.string   "owner_type",     limit: 255
    t.string   "key",            limit: 255
    t.text     "parameters",     limit: 65535
    t.integer  "recipient_id",   limit: 4
    t.string   "recipient_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activities", ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type", using: :btree
  add_index "activities", ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type", using: :btree
  add_index "activities", ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type", using: :btree

  create_table "api_settings", force: :cascade do |t|
    t.string   "endpoint",   limit: 255
    t.string   "auth_token", limit: 255
    t.string   "homepage",   limit: 255
    t.string   "slug",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "auth_email", limit: 255
  end

  add_index "api_settings", ["slug"], name: "index_api_settings_on_slug", unique: true, using: :btree

  create_table "custom_ink_color_trains", force: :cascade do |t|
    t.string   "state",         limit: 255
    t.integer  "job_id",        limit: 4
    t.string   "pantone_color", limit: 255
    t.string   "volume",        limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "fba_bagging_trains", force: :cascade do |t|
    t.string   "state",            limit: 255
    t.integer  "machine_id",       limit: 4
    t.integer  "completed_by_id",  limit: 4
    t.datetime "scheduled_at"
    t.decimal  "estimated_time",               precision: 10, scale: 2
    t.datetime "estimated_end_at"
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.integer  "order_id",         limit: 4
  end

  create_table "fba_label_trains", force: :cascade do |t|
    t.string   "state",      limit: 255
    t.integer  "order_id",   limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
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

  create_table "imprint_groups", force: :cascade do |t|
    t.integer  "order_id",                limit: 4
    t.datetime "scheduled_at"
    t.datetime "estimated_end_at"
    t.decimal  "estimated_time",                      precision: 10, scale: 2
    t.integer  "machine_id",              limit: 4
    t.datetime "completed_at"
    t.integer  "completed_by_id",         limit: 4
    t.boolean  "require_manager_signoff"
    t.string   "type",                    limit: 255
    t.datetime "created_at",                                                   null: false
    t.datetime "updated_at",                                                   null: false
  end

  create_table "imprintable_trains", force: :cascade do |t|
    t.integer  "job_id",                limit: 4
    t.string   "state",                 limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "location",              limit: 255
    t.datetime "expected_arrival_date"
  end

  create_table "imprints", force: :cascade do |t|
    t.integer  "softwear_crm_id",         limit: 4
    t.integer  "job_id",                  limit: 4
    t.datetime "scheduled_at"
    t.datetime "estimated_end_at"
    t.decimal  "estimated_time",                        precision: 10, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "machine_id",              limit: 4
    t.string   "name",                    limit: 255
    t.text     "description",             limit: 65535
    t.datetime "completed_at"
    t.integer  "completed_by_id",         limit: 4
    t.string   "state",                   limit: 255
    t.string   "type",                    limit: 255
    t.integer  "count",                   limit: 4
    t.boolean  "require_manager_signoff"
    t.integer  "imprint_group_id",        limit: 4
  end

  add_index "imprints", ["machine_id"], name: "index_imprints_on_machine_id", using: :btree

  create_table "jobs", force: :cascade do |t|
    t.integer  "softwear_crm_id", limit: 4
    t.integer  "order_id",        limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",            limit: 255
  end

  create_table "local_delivery_trains", force: :cascade do |t|
    t.string   "state",             limit: 255
    t.integer  "delivered_by_id",   limit: 4
    t.string   "delivered_to_name", limit: 255
    t.integer  "order_id",          limit: 4
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "local_delivery_trains", ["delivered_by_id"], name: "index_local_delivery_trains_on_delivered_by_id", using: :btree
  add_index "local_delivery_trains", ["order_id"], name: "index_local_delivery_trains_on_order_id", using: :btree
  add_index "local_delivery_trains", ["state"], name: "index_local_delivery_trains_on_state", using: :btree

  create_table "machines", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "color",      limit: 255
  end

  create_table "maintenances", force: :cascade do |t|
    t.datetime "scheduled_at"
    t.decimal  "estimated_time",               precision: 10, scale: 2
    t.datetime "estimated_end_at"
    t.integer  "machine_id",       limit: 4
    t.datetime "completed_at"
    t.integer  "completed_by_id",  limit: 4
    t.string   "name",             limit: 255
    t.string   "description",      limit: 255
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
  end

  create_table "orders", force: :cascade do |t|
    t.integer  "softwear_crm_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deadline"
    t.string   "name",               limit: 255
    t.boolean  "fba"
    t.boolean  "has_imprint_groups"
  end

  create_table "preproduction_notes_trains", force: :cascade do |t|
    t.text     "decoration_placement", limit: 65535
    t.text     "print_order",          limit: 65535
    t.text     "special_instructions", limit: 65535
    t.integer  "job_id",               limit: 4
    t.string   "state",                limit: 255
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  create_table "roles", force: :cascade do |t|
    t.string "name", limit: 255
  end

  create_table "screens", force: :cascade do |t|
    t.string   "frame_type", limit: 255
    t.string   "dimensions", limit: 255
    t.string   "mesh_type",  limit: 255
    t.string   "state",      limit: 255
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shipment_trains", force: :cascade do |t|
    t.string   "state",         limit: 255
    t.integer  "shipped_by_id", limit: 4
    t.datetime "shipped_at"
    t.string   "carrier",       limit: 255
    t.string   "service",       limit: 255
    t.string   "tracking",      limit: 255
    t.integer  "order_id",      limit: 4
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "stage_for_fba_bagging_trains", force: :cascade do |t|
    t.string   "state",      limit: 255
    t.string   "location",   limit: 255
    t.integer  "order_id",   limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "stage_for_fba_bagging_trains", ["location"], name: "index_stage_for_fba_bagging_trains_on_location", using: :btree
  add_index "stage_for_fba_bagging_trains", ["order_id"], name: "index_stage_for_fba_bagging_trains_on_order_id", using: :btree
  add_index "stage_for_fba_bagging_trains", ["state"], name: "index_stage_for_fba_bagging_trains_on_state", using: :btree

  create_table "stage_for_pickup_trains", force: :cascade do |t|
    t.string   "state",      limit: 255
    t.string   "location",   limit: 255
    t.integer  "order_id",   limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "stage_for_pickup_trains", ["location"], name: "index_stage_for_pickup_trains_on_location", using: :btree
  add_index "stage_for_pickup_trains", ["order_id"], name: "index_stage_for_pickup_trains_on_order_id", using: :btree
  add_index "stage_for_pickup_trains", ["state"], name: "index_stage_for_pickup_trains_on_state", using: :btree

  create_table "store_delivery_trains", force: :cascade do |t|
    t.string   "state",           limit: 255
    t.integer  "delivered_by_id", limit: 4
    t.string   "store_name",      limit: 255
    t.integer  "order_id",        limit: 4
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "store_delivery_trains", ["delivered_by_id"], name: "index_store_delivery_trains_on_delivered_by_id", using: :btree
  add_index "store_delivery_trains", ["order_id"], name: "index_store_delivery_trains_on_order_id", using: :btree
  add_index "store_delivery_trains", ["state"], name: "index_store_delivery_trains_on_state", using: :btree
  add_index "store_delivery_trains", ["store_name"], name: "index_store_delivery_trains_on_store_name", using: :btree

  create_table "train_autocompletes", force: :cascade do |t|
    t.string   "field",      limit: 255
    t.string   "value",      limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "train_autocompletes", ["field"], name: "index_train_autocompletes_on_field", using: :btree

  create_table "user_roles", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",    limit: 4
    t.integer  "role_id",    limit: 4
  end

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
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "first_name",             limit: 255
    t.string   "last_name",              limit: 255
    t.string   "authentication_token",   limit: 255
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "warning_emails", force: :cascade do |t|
    t.string  "model",     limit: 255
    t.decimal "minutes",               precision: 10, scale: 2
    t.string  "recipient", limit: 255
    t.string  "url",       limit: 255
  end

  create_table "warnings", force: :cascade do |t|
    t.integer  "warnable_id",   limit: 4
    t.string   "warnable_type", limit: 255
    t.string   "source",        limit: 255
    t.text     "message",       limit: 65535
    t.datetime "dismissed_at"
    t.integer  "dismisser_id",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
