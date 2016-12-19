class AddStitchCountUsesLaserAndLaserStitchCountToDigitizationTrain < ActiveRecord::Migration
  def change
    add_column :digitization_trains, :stitch_count,       :integer
    add_column :digitization_trains, :uses_laser,         :boolean
    add_column :digitization_trains, :laser_stitch_count, :integer
  end
end
