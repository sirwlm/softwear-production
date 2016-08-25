require 'csv'

namespace :screens do
  task dry: :environment do
    Screen.dry_screens
  end

  task fix_screen_activities: :environment do

    test = true
    
    CSV.foreach([Rails.root, "ScreenReclaim_activity_fix.csv"].join('/'), headers: true) do |csv_obj|
      activity_id  = csv_obj['activity_id'].blank? ? nil : csv_obj['activity_id'].to_i
      new_owner_id = csv_obj['correct_owner_id'].blank? ? nil : csv_obj['correct_owner_id'].to_i

      next if activity_id.nil? && new_owner_id.nil?

      activity = PublicActivity::Activity.find_by(id: activity_id)
     
      next if activity.nil?

      activity.update(owner_id: new_owner_id)
    end
  end
end
