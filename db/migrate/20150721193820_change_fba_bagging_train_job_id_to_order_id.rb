class ChangeFbaBaggingTrainJobIdToOrderId < ActiveRecord::Migration
  def change
    remove_column :fba_bagging_trains, :job_id, :integer
    add_column :fba_bagging_trains, :order_id, :integer
  end
end
