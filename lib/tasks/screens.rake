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

      activity.update(owner_id: new_owner_id, owner_type: "User")
    end
  end

  task create_missing_screen_activities: :environment do
    index = 0
    
    screen_trains = []
    dates_to_find = []

    start_date = DateTime.new(2016,5,1)
    end_date   = DateTime.new(2016,6,30, 23, 59, 59)

    activities = PublicActivity::Activity.where("parameters like ?", "%event%screens_assigned%")
    activities = activities.where("created_at >= ? AND created_at <= ?", start_date, end_date)

    # will get all activites and dates to check for exposed screen activity
    activities.each do |activity|
      next if activity.trackable.nil?
      
      screen_trains << activity.trackable
      dates_to_find << activity.created_at
    end

    screen_trains.each do |screen_train|
      screen_train.screens.each do |screen|
        screen_activities = screen.activities.flat_map{ |a| a }
        # get activities with matching date of screen_train's assigned_screens activity date
        screen_activities = screen_activities.delete_if{ 
          |a| a.created_at.strftime("%Y/%m/%d") != dates_to_find[index].strftime("%Y/%m/%d")
                  }

        # get screens that don't have exposed activity
        screen_activities = screen_activities.delete_if{ |a| a.parameters["event"] != "exposed" }
      
        # if screen_activities are blank, no exposed was created for this screen
        if screen_activities.blank?
          screen.create_activity(
            action: :transition,
            parameters: {
              event: "exposed",
              mesh_type: screen.mesh_type
            },
            owner_id: 999,
            created_at: dates_to_find[index]
          )
          next
        else
          next
        end
      end
      index += 1
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
