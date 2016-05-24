class RemoveLocationFromStageForFbaBaggingTrain < ActiveRecord::Migration
  def change
    trains = StageForFbaBaggingTrain.all
    trains.each{ |t| t.update_column(:inventory_location, t.location) }

    remove_column :stage_for_fba_bagging_trains, :location, :string, index: true
  end
end
