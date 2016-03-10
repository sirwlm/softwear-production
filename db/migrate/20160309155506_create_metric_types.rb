class CreateMetricTypes < ActiveRecord::Migration
  def change
    create_table :metric_types do |t|
      t.string :name, index: true
      t.string :metric_type_class, index: true
      t.string :measurement_type, index: true
      t.string :activity, index: true
      t.string :start_activity, index: true
      t.string :end_activity, index: true

      t.timestamps null: false
    end
  end
end
