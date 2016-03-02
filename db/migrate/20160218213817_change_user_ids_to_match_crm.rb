class ChangeUserIdsToMatchCrm < ActiveRecord::Migration
  class Hub < ActiveRecord::Base
    def self.abstract_class?
      true
    end
  end

  def up
    unless Rails.env.test?
      user_id_fields = Hash[
        ActiveRecord::Base.descendants.map do |model|
          [
            model,
            model.reflect_on_all_associations
              .select { |assoc| assoc.is_a?(ActiveRecord::Reflection::BelongsToReflection) }
              .select { |assoc| assoc.class_name == 'User' }
              .map(&:foreign_key)
          ]
        end
          .reject { |entry| entry.last.empty? }
      ]
      hub_user_id_mapping = {}

      hub_connection = Hub.establish_connection("#{Rails.env}_hub").connection
      result = hub_connection.execute("SELECT * from users")

      result.each(as: :hash) do |row|
        existing_user = User.unscoped.find_by email: row['email']
        next if existing_user.nil?
        hub_user_id_mapping[existing_user.id.to_i] = row['id'].to_i
      end

      ActiveRecord::Base.transaction do
        user_id_fields.each do |model, user_fields|
          model.unscoped.find_each do |record|

            user_fields.each do |field|
              next unless record.respond_to?(field)

              old_id = record.send(field)
              next if old_id.nil?
              new_id = hub_user_id_mapping[old_id.to_i]
              next if new_id.nil?

              record.send("#{field}=", new_id)
            end

            record.save(validate: false)
          end

          user_fields.each do |field|
            puts "Map ID -> hub ID: #{model.name}##{field}"
          end
        end

        PublicActivity::Activity.unscoped.where(owner_type: 'User').find_each do |activity|
          activity.owner_id = hub_user_id_mapping[activity.owner_id]
          activity.save(validate: false)
        end
        puts "Map ID -> hub ID: PublicActivity::Activity#owner:user"

        PublicActivity::Activity.unscoped.where(recipient_type: 'User').find_each do |activity|
          activity.recipient_id = hub_user_id_mapping[activity.recipient_id]
          activity.save(validate: false)
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
