class CollateWithUtf8mb4UnicodeCi < ActiveRecord::Migration
  def up
    string_columns = {"activities"=>["trackable_type", "owner_type", "key", "recipient_type"], "api_settings"=>["endpoint", "auth_token", "homepage", "slug", "auth_email"], "ar3_trains"=>["state", "artwork_location", "previous_state"], "assigned_screens"=>["double_position"], "custom_ink_color_trains"=>["state", "pantone_color", "volume", "previous_state"], "digitization_trains"=>["state", "artwork_location", "third_party_name", "previous_state"], "fba_bagging_trains"=>["state", "previous_state"], "fba_label_trains"=>["state", "previous_state"], "friendly_id_slugs"=>["slug", "sluggable_type", "scope"], "imprint_groups"=>["type"], "imprintable_trains"=>["state", "location", "previous_state"], "imprints"=>["name", "state", "type", "triloc_result", "previous_state"], "jobs"=>["name"], "local_delivery_trains"=>["state", "delivered_to_name", "previous_state"], "machines"=>["name", "color"], "maintenances"=>["name", "description"], "orders"=>["name", "customer_name"], "preproduction_notes_trains"=>["state", "previous_state"], "roles"=>["name"], "screen_requests"=>["frame_type", "mesh_type", "dimensions", "ink"], "screen_trains"=>["state", "garment_material", "garment_weight", "artwork_location", "print_type", "lpi", "previous_state"], "screens"=>["frame_type", "dimensions", "mesh_type", "state"], "shipment_trains"=>["state", "carrier", "service", "tracking", "shipment_holder_type", "previous_state"], "stage_for_fba_bagging_trains"=>["state", "location", "previous_state"], "stage_for_pickup_trains"=>["state", "location", "previous_state"], "store_delivery_trains"=>["state", "store_name", "previous_state"], "train_autocompletes"=>["field", "value"], "users"=>["email", "encrypted_password", "reset_password_token", "current_sign_in_ip", "last_sign_in_ip", "confirmation_token", "unconfirmed_email", "first_name", "last_name", "authentication_token"], "warning_emails"=>["model", "recipient", "url"], "warnings"=>["warnable_type", "source"]}
    text_columns = columns = {"activities"=>["parameters"], "ar3_trains"=>["notes"], "digitization_trains"=>["notes"], "imprints"=>["description"], "preproduction_notes_trains"=>["decoration_placement", "print_order", "special_instructions"], "screen_trains"=>["notes"], "warnings"=>["message"]}

    string_columns.each do |table, columns|
      columns.each do |column|
        execute "ALTER TABLE `#{table}` MODIFY `#{column}` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
      end
    end
    text_columns.each do |table, columns|
      columns.each do |column|
        execute "ALTER TABLE `#{table}` MODIFY `#{column}` MEDIUMTEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
      end
    end

    all_tables = %w(activities api_settings ar3_trains assigned_screens custom_ink_color_trains digital_print_users digitization_trains fba_bagging_trains fba_label_trains friendly_id_slugs imprint_groups imprintable_trains imprints jobs local_delivery_trains machines maintenances orders preproduction_notes_trains roles screen_requests screen_trains screens shipment_trains stage_for_fba_bagging_trains stage_for_pickup_trains store_delivery_trains train_autocompletes user_roles users warning_emails warnings)
    all_tables.each do |table|
      execute "ALTER TABLE `#{table}` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
    end
  end

  def down
  end
end
