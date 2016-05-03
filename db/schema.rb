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

ActiveRecord::Schema.define(version: 20160503173946) do

  create_table "activities", force: :cascade do |t|
    t.integer  "trackable_id",   limit: 4
    t.string   "trackable_type", limit: 191
    t.integer  "owner_id",       limit: 4
    t.string   "owner_type",     limit: 191
    t.string   "key",            limit: 191
    t.text     "parameters",     limit: 16777215
    t.integer  "recipient_id",   limit: 4
    t.string   "recipient_type", limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activities", ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type", using: :btree
  add_index "activities", ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type", using: :btree
  add_index "activities", ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type", using: :btree

  create_table "api_settings", force: :cascade do |t|
    t.string   "endpoint",   limit: 191
    t.string   "auth_token", limit: 191
    t.string   "homepage",   limit: 191
    t.string   "slug",       limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "auth_email", limit: 191
  end

  add_index "api_settings", ["slug"], name: "index_api_settings_on_slug", unique: true, using: :btree

  create_table "ar3_trains", force: :cascade do |t|
    t.string   "state",                  limit: 191
    t.integer  "order_id",               limit: 4
    t.string   "artwork_location",       limit: 191
    t.text     "notes",                  limit: 16777215
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.integer  "crm_artwork_request_id", limit: 4
    t.string   "previous_state",         limit: 191
    t.string   "final_ar3_location",     limit: 191
  end

  create_table "assigned_screens", force: :cascade do |t|
    t.integer  "screen_request_id", limit: 4
    t.integer  "screen_train_id",   limit: 4
    t.integer  "screen_id",         limit: 4
    t.string   "double_position",   limit: 191
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "assigned_screens", ["double_position"], name: "index_assigned_screens_on_double_position", using: :btree
  add_index "assigned_screens", ["screen_id"], name: "index_assigned_screens_on_screen_id", using: :btree
  add_index "assigned_screens", ["screen_request_id"], name: "index_assigned_screens_on_screen_request_id", using: :btree
  add_index "assigned_screens", ["screen_train_id"], name: "index_assigned_screens_on_screen_train_id", using: :btree

  create_table "custom_ink_color_trains", force: :cascade do |t|
    t.string   "state",          limit: 191
    t.integer  "job_id",         limit: 4
    t.string   "pantone_color",  limit: 191
    t.string   "volume",         limit: 191
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "previous_state", limit: 191
    t.string   "name",           limit: 191
    t.text     "notes",          limit: 65535
    t.datetime "scheduled"
  end

  create_table "digital_print_users", force: :cascade do |t|
    t.integer  "user_id",          limit: 4
    t.integer  "digital_print_id", limit: 4
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "digital_print_users", ["digital_print_id"], name: "index_digital_print_users_on_digital_print_id", using: :btree
  add_index "digital_print_users", ["user_id"], name: "index_digital_print_users_on_user_id", using: :btree

  create_table "digitization_trains", force: :cascade do |t|
    t.string   "state",                       limit: 191
    t.string   "artwork_location",            limit: 191
    t.string   "third_party_name",            limit: 191
    t.integer  "digitization_assigned_to_id", limit: 4
    t.integer  "approved_by_id",              limit: 4
    t.integer  "order_id",                    limit: 4
    t.text     "notes",                       limit: 16777215
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.integer  "crm_artwork_request_id",      limit: 4
    t.string   "previous_state",              limit: 191
    t.datetime "scheduled"
  end

  create_table "fba_bagging_trains", force: :cascade do |t|
    t.string   "state",              limit: 191
    t.integer  "machine_id",         limit: 4
    t.integer  "completed_by_id",    limit: 4
    t.datetime "scheduled_at"
    t.decimal  "estimated_time",                 precision: 10, scale: 2
    t.datetime "estimated_end_at"
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.integer  "order_id",           limit: 4
    t.datetime "completed_at"
    t.string   "previous_state",     limit: 191
    t.string   "inventory_location", limit: 191
  end

  create_table "fba_label_trains", force: :cascade do |t|
    t.string   "state",          limit: 191
    t.integer  "order_id",       limit: 4
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "previous_state", limit: 191
    t.datetime "scheduled"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string   "slug",           limit: 191
    t.integer  "sluggable_id",   limit: 4,   null: false
    t.string   "sluggable_type", limit: 191
    t.string   "scope",          limit: 191
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
    t.string   "type",                    limit: 191
    t.datetime "created_at",                                                   null: false
    t.datetime "updated_at",                                                   null: false
    t.datetime "started_at"
    t.integer  "softwear_crm_id",         limit: 4
    t.string   "name",                    limit: 191
  end

  create_table "imprintable_trains", force: :cascade do |t|
    t.integer  "job_id",                limit: 4
    t.string   "state",                 limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "location",              limit: 191
    t.datetime "expected_arrival_date"
    t.string   "previous_state",        limit: 191
    t.datetime "scheduled"
  end

  create_table "imprints", force: :cascade do |t|
    t.integer  "softwear_crm_id",         limit: 4
    t.integer  "job_id",                  limit: 4
    t.datetime "scheduled_at"
    t.datetime "estimated_end_at"
    t.decimal  "estimated_time",                           precision: 10, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "machine_id",              limit: 4
    t.string   "name",                    limit: 191
    t.text     "description",             limit: 16777215
    t.datetime "completed_at"
    t.integer  "completed_by_id",         limit: 4
    t.string   "state",                   limit: 191
    t.string   "type",                    limit: 191
    t.integer  "count",                   limit: 4
    t.boolean  "require_manager_signoff"
    t.integer  "imprint_group_id",        limit: 4
    t.integer  "screen_train_id",         limit: 4
    t.datetime "started_at"
    t.string   "triloc_result",           limit: 191
    t.boolean  "revolved"
    t.string   "previous_state",          limit: 191
  end

  add_index "imprints", ["machine_id"], name: "index_imprints_on_machine_id", using: :btree

  create_table "jobs", force: :cascade do |t|
    t.integer  "softwear_crm_id", limit: 4
    t.integer  "order_id",        limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",            limit: 191
  end

  create_table "local_delivery_trains", force: :cascade do |t|
    t.string   "state",             limit: 191
    t.integer  "delivered_by_id",   limit: 4
    t.string   "delivered_to_name", limit: 191
    t.integer  "order_id",          limit: 4
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "previous_state",    limit: 191
    t.integer  "softwear_crm_id",   limit: 4
  end

  add_index "local_delivery_trains", ["delivered_by_id"], name: "index_local_delivery_trains_on_delivered_by_id", using: :btree
  add_index "local_delivery_trains", ["order_id"], name: "index_local_delivery_trains_on_order_id", using: :btree
  add_index "local_delivery_trains", ["state"], name: "index_local_delivery_trains_on_state", using: :btree

  create_table "machines", force: :cascade do |t|
    t.string   "name",       limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "color",      limit: 191
  end

  create_table "maintenances", force: :cascade do |t|
    t.datetime "scheduled_at"
    t.decimal  "estimated_time",               precision: 10, scale: 2
    t.datetime "estimated_end_at"
    t.integer  "machine_id",       limit: 4
    t.datetime "completed_at"
    t.integer  "completed_by_id",  limit: 4
    t.string   "name",             limit: 191
    t.string   "description",      limit: 191
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
  end

  create_table "metric_types", force: :cascade do |t|
    t.string   "name",              limit: 191
    t.string   "metric_type_class", limit: 191
    t.string   "measurement_type",  limit: 191
    t.string   "activity",          limit: 191
    t.string   "start_activity",    limit: 191
    t.string   "end_activity",      limit: 191
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "metric_types", ["activity"], name: "index_metric_types_on_activity", using: :btree
  add_index "metric_types", ["end_activity"], name: "index_metric_types_on_end_activity", using: :btree
  add_index "metric_types", ["measurement_type"], name: "index_metric_types_on_measurement_type", using: :btree
  add_index "metric_types", ["metric_type_class"], name: "index_metric_types_on_metric_type_class", using: :btree
  add_index "metric_types", ["name"], name: "index_metric_types_on_name", using: :btree
  add_index "metric_types", ["start_activity"], name: "index_metric_types_on_start_activity", using: :btree

  create_table "metrics", force: :cascade do |t|
    t.integer  "metric_type_id",  limit: 4
    t.string   "name",            limit: 191
    t.integer  "metricable_id",   limit: 4
    t.string   "metricable_type", limit: 191
    t.integer  "value",           limit: 4
    t.boolean  "valid_data"
    t.string   "invalid_reason",  limit: 191
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "metrics", ["metricable_id"], name: "index_metrics_on_metricable_id", using: :btree
  add_index "metrics", ["metricable_type"], name: "index_metrics_on_metricable_type", using: :btree
  add_index "metrics", ["name"], name: "index_metrics_on_name", using: :btree
  add_index "metrics", ["valid_data"], name: "index_metrics_on_valid_data", using: :btree

  create_table "old_users", force: :cascade do |t|
    t.string   "email",                  limit: 191
    t.string   "encrypted_password",     limit: 191
    t.string   "reset_password_token",   limit: 191
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 191
    t.string   "last_sign_in_ip",        limit: 191
    t.string   "confirmation_token",     limit: 191
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",      limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "first_name",             limit: 191
    t.string   "last_name",              limit: 191
    t.string   "authentication_token",   limit: 191
  end

  add_index "old_users", ["authentication_token"], name: "index_old_users_on_authentication_token", using: :btree
  add_index "old_users", ["email"], name: "index_old_users_on_email", unique: true, using: :btree
  add_index "old_users", ["reset_password_token"], name: "index_old_users_on_reset_password_token", unique: true, using: :btree

  create_table "orders", force: :cascade do |t|
    t.integer  "softwear_crm_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deadline"
    t.string   "name",               limit: 191
    t.boolean  "fba"
    t.boolean  "has_imprint_groups"
    t.string   "customer_name",      limit: 191
    t.boolean  "canceled"
  end

  create_table "preproduction_notes_trains", force: :cascade do |t|
    t.text     "decoration_placement", limit: 16777215
    t.text     "print_order",          limit: 16777215
    t.text     "special_instructions", limit: 16777215
    t.integer  "job_id",               limit: 4
    t.string   "state",                limit: 191
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.string   "previous_state",       limit: 191
    t.datetime "scheduled"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name", limit: 191
  end

  create_table "screen_requests", force: :cascade do |t|
    t.integer  "screen_train_id", limit: 4
    t.string   "frame_type",      limit: 191
    t.string   "mesh_type",       limit: 191
    t.string   "dimensions",      limit: 191
    t.string   "ink",             limit: 191
    t.boolean  "primary"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "screen_requests", ["dimensions"], name: "index_screen_requests_on_dimensions", using: :btree
  add_index "screen_requests", ["frame_type"], name: "index_screen_requests_on_frame_type", using: :btree
  add_index "screen_requests", ["ink"], name: "index_screen_requests_on_ink", using: :btree
  add_index "screen_requests", ["mesh_type"], name: "index_screen_requests_on_mesh_type", using: :btree
  add_index "screen_requests", ["primary"], name: "index_screen_requests_on_primary", using: :btree
  add_index "screen_requests", ["screen_train_id"], name: "index_screen_requests_on_screen_train_id", using: :btree

  create_table "screen_trains", force: :cascade do |t|
    t.string   "state",                  limit: 191
    t.integer  "order_id",               limit: 4
    t.decimal  "separation_time",                         precision: 10, scale: 2
    t.boolean  "new_separation"
    t.datetime "due_at"
    t.integer  "signed_off_by_id",       limit: 4
    t.integer  "assigned_to_id",         limit: 4
    t.text     "notes",                  limit: 16777215
    t.string   "garment_material",       limit: 191
    t.string   "garment_weight",         limit: 191
    t.string   "artwork_location",       limit: 191
    t.string   "print_type",             limit: 191
    t.datetime "created_at",                                                       null: false
    t.datetime "updated_at",                                                       null: false
    t.string   "lpi",                    limit: 191
    t.integer  "crm_artwork_request_id", limit: 4
    t.string   "previous_state",         limit: 191
    t.datetime "scheduled"
  end

  add_index "screen_trains", ["artwork_location"], name: "index_screen_trains_on_artwork_location", using: :btree
  add_index "screen_trains", ["assigned_to_id"], name: "index_screen_trains_on_assigned_to_id", using: :btree
  add_index "screen_trains", ["due_at"], name: "index_screen_trains_on_due_at", using: :btree
  add_index "screen_trains", ["garment_material"], name: "index_screen_trains_on_garment_material", using: :btree
  add_index "screen_trains", ["garment_weight"], name: "index_screen_trains_on_garment_weight", using: :btree
  add_index "screen_trains", ["new_separation"], name: "index_screen_trains_on_new_separation", using: :btree
  add_index "screen_trains", ["order_id"], name: "index_screen_trains_on_order_id", using: :btree
  add_index "screen_trains", ["print_type"], name: "index_screen_trains_on_print_type", using: :btree
  add_index "screen_trains", ["separation_time"], name: "index_screen_trains_on_separation_time", using: :btree
  add_index "screen_trains", ["signed_off_by_id"], name: "index_screen_trains_on_signed_off_by_id", using: :btree
  add_index "screen_trains", ["state"], name: "index_screen_trains_on_state", using: :btree

  create_table "screens", force: :cascade do |t|
    t.string   "frame_type", limit: 191
    t.string   "dimensions", limit: 191
    t.string   "mesh_type",  limit: 191
    t.string   "state",      limit: 191
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shipment_trains", force: :cascade do |t|
    t.string   "state",                limit: 191
    t.integer  "shipped_by_id",        limit: 4
    t.datetime "shipped_at"
    t.string   "carrier",              limit: 191
    t.string   "service",              limit: 191
    t.string   "tracking",             limit: 191
    t.datetime "created_at",                                                null: false
    t.datetime "updated_at",                                                null: false
    t.decimal  "time_in_transit",                  precision: 10, scale: 2
    t.integer  "shipment_holder_id",   limit: 4
    t.string   "shipment_holder_type", limit: 191
    t.string   "previous_state",       limit: 191
    t.integer  "created_by_id",        limit: 4
    t.integer  "softwear_crm_id",      limit: 4
  end

  create_table "stage_for_fba_bagging_trains", force: :cascade do |t|
    t.string   "state",              limit: 191
    t.integer  "order_id",           limit: 4
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "previous_state",     limit: 191
    t.string   "inventory_location", limit: 191
  end

  add_index "stage_for_fba_bagging_trains", ["order_id"], name: "index_stage_for_fba_bagging_trains_on_order_id", using: :btree
  add_index "stage_for_fba_bagging_trains", ["state"], name: "index_stage_for_fba_bagging_trains_on_state", using: :btree

  create_table "stage_for_pickup_trains", force: :cascade do |t|
    t.string   "state",          limit: 191
    t.string   "location",       limit: 191
    t.integer  "order_id",       limit: 4
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "previous_state", limit: 191
  end

  add_index "stage_for_pickup_trains", ["location"], name: "index_stage_for_pickup_trains_on_location", using: :btree
  add_index "stage_for_pickup_trains", ["order_id"], name: "index_stage_for_pickup_trains_on_order_id", using: :btree
  add_index "stage_for_pickup_trains", ["state"], name: "index_stage_for_pickup_trains_on_state", using: :btree

  create_table "store_delivery_trains", force: :cascade do |t|
    t.string   "state",           limit: 191
    t.integer  "delivered_by_id", limit: 4
    t.string   "store_name",      limit: 191
    t.integer  "order_id",        limit: 4
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "previous_state",  limit: 191
  end

  add_index "store_delivery_trains", ["delivered_by_id"], name: "index_store_delivery_trains_on_delivered_by_id", using: :btree
  add_index "store_delivery_trains", ["order_id"], name: "index_store_delivery_trains_on_order_id", using: :btree
  add_index "store_delivery_trains", ["state"], name: "index_store_delivery_trains_on_state", using: :btree
  add_index "store_delivery_trains", ["store_name"], name: "index_store_delivery_trains_on_store_name", using: :btree

  create_table "train_autocompletes", force: :cascade do |t|
    t.string   "field",      limit: 191
    t.string   "value",      limit: 191
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
    t.string   "email",                  limit: 191
    t.string   "encrypted_password",     limit: 191
    t.string   "reset_password_token",   limit: 191
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 191
    t.string   "last_sign_in_ip",        limit: 191
    t.string   "confirmation_token",     limit: 191
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",      limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "first_name",             limit: 191
    t.string   "last_name",              limit: 191
    t.string   "authentication_token",   limit: 191
    t.string   "default_view",           limit: 191
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "warning_emails", force: :cascade do |t|
    t.string  "model",     limit: 191
    t.decimal "minutes",               precision: 10, scale: 2
    t.string  "recipient", limit: 191
    t.string  "url",       limit: 191
  end

  create_table "warnings", force: :cascade do |t|
    t.integer  "warnable_id",   limit: 4
    t.string   "warnable_type", limit: 191
    t.string   "source",        limit: 191
    t.text     "message",       limit: 16777215
    t.datetime "dismissed_at"
    t.integer  "dismisser_id",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
