class AddScaleToImportantDecimalFields < ActiveRecord::Migration
  def change
    change_column :fba_bagging_trains, :estimated_time, :decimal, scale: 2, precision: 10
    change_column :maintenances, :estimated_time,       :decimal, scale: 2, precision: 10
    change_column :imprint_groups, :estimated_time,     :decimal, scale: 2, precision: 10
  end
end
