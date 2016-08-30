require 'csv'

namespace :screens do
  task dry: :environment do
    Screen.dry_screens
  end

  # CSV file should have activity_id/correct_owner_id headers
  task fix_screen_wrong_user_activities: :environment do
    CSV.foreach([Rails.root, "ScreenReclaim_activity_fix.csv"].join('/'), headers: true) do |csv_obj|
      activity_id  = csv_obj['activity_id'].blank? ? nil : csv_obj['activity_id'].to_i
      new_owner_id = csv_obj['correct_owner_id'].blank? ? nil : csv_obj['correct_owner_id'].to_i

      next if activity_id.nil? && new_owner_id.nil?

      activity = PublicActivity::Activity.find_by(id: activity_id)
     
      next if activity.nil?

      activity.update(owner_id: new_owner_id)
    end
  end

  task fix_bad_screen_activity_event: :environment do 
    # will get all activities with "event"=>"washed_out_and_drying"
    activities = PublicActivity::Activity.where("parameters like ?", '%"event"%"washed_out_and_drying"%')

    activities.each do |activity|
      activity.parameters["event"] = "exposed"
      activity.save  
    end
  end
end
