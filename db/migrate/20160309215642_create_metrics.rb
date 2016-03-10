class CreateMetrics < ActiveRecord::Migration
  def change
    create_table :metrics do |t|
      t.integer :metric_type_id
      t.string :name, index: true
      t.integer :metricable_id, index: true
      t.string :metricable_type, index: true
      t.integer :value
      t.boolean :valid_data, index: true
      t.string :invalid_reason
      t.timestamps null: false
    end
  end
end
