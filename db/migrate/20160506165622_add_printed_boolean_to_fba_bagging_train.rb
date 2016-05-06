class AddPrintedBooleanToFbaBaggingTrain < ActiveRecord::Migration
  def change
    if column_exists?(:fba_bagging_trains, :printed)
      FbaBaggingTrain.all.each do |fba|
        if fba.printed.nil?
          fba.update_attributes(printed: false)
        end
      end
    else
      add_column :fba_bagging_trains, :printed, :boolean, default: false
    end
  end
end
