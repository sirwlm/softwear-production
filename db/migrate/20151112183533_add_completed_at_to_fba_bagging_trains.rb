class AddCompletedAtToFbaBaggingTrains < ActiveRecord::Migration
  def up
    add_column :fba_bagging_trains, :completed_at, :datetime
    puts "-- updating completed_at values"
    FbaBaggingTrain.unscoped.find_each do |fbt|
      fbt.update_column :completed_at, fbt.old_completed_at
    end
  end
  def down
    remove_column :fba_bagging_trains, :completed_at, :datetime
  end
end
