class ChangeUserIdsToMatchCrm < ActiveRecord::Migration
  class Hub < ActiveRecord::Base
    def self.abstract_class?
      true
    end
  end

  def up
    unless Rails.env.test?
      user_id_fields = {"Imprint"=>["completed_by_id"], "ImprintGroup"=>["completed_by_id"], "FbaBaggingTrain"=>["completed_by_id"], "StoreDeliveryTrain"=>[:delivered_by_id], "DigitalPrintUser"=>["user_id"], "ScreenTrain"=>[:assigned_to_id], "EmbroideryPrint"=>["completed_by_id"], "Print"=>["completed_by_id"], "TransferMakingPrint"=>["completed_by_id"], "EquipmentCleaningPrint"=>["completed_by_id"], "ScreenPrint"=>["completed_by_id"], "TransferPrint"=>["completed_by_id"], "DigitalPrint"=>["completed_by_id"], "ButtonMakingPrint"=>["completed_by_id"]}

      hub_user_id_mapping = {}

      hub_connection = Hub.establish_connection("#{Rails.env}_hub").connection
      result = hub_connection.execute("SELECT * from users")

      result.each(as: :hash) do |row|
        existing_users = ActiveRecord::Base.connection.execute(
          "SELECT id FROM users WHERE email = \"#{row['email']}\""
        )

        existing_users.each(as: :hash) do |existing_user|
          old_id = existing_user['id'].to_i
          new_id = row['id'].to_i
          next if old_id == new_id

          hub_user_id_mapping[old_id] = new_id
          next
        end
      end

      puts "PROD -> HUB mapping:\n#{JSON.pretty_generate(hub_user_id_mapping)}"

      ActiveRecord::Base.transaction do
        user_id_fields.each do |model_name, user_fields|
          model = model_name.constantize
          model.unscoped.find_each do |record|

            user_fields.each do |field|
              next unless record.respond_to?(field)

              old_id = record.send(field)
              next if old_id.nil?
              new_id = hub_user_id_mapping[old_id.to_i]
              next if new_id.nil?
              next if old_id.to_i == new_id.to_i

              record.update_column field, new_id
            end
          end

          user_fields.each do |field|
            puts "Map ID -> hub ID: #{model.name}##{field}"
          end
        end

        PublicActivity::Activity.unscoped.where(owner_type: 'User').find_each do |activity|
          activity.update_column :owner_id, hub_user_id_mapping[activity.owner_id]
        end
        puts "Map ID -> hub ID: PublicActivity::Activity#owner:user"

        PublicActivity::Activity.unscoped.where(recipient_type: 'User').find_each do |activity|
          activity.update_column :recipient_id, hub_user_id_mapping[activity.recipient_id]
        end
        puts "Map ID -> hub ID: PublicActivity::Activity#recipient:user"
      end# of transaction
    end

    rename_table :users, :old_users
  end

  def down
    rename_table :old_users, :users
  end
end
