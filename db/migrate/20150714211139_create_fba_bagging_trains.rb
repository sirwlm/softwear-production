class CreateFbaBaggingTrains < ActiveRecord::Migration
  def change
    create_table :fba_bagging_trains do |t|
      t.integer :job_id
      t.string :state
      t.integer :machine_id
      t.integer :completed_by_id
      t.datetime :scheduled_at
      t.decimal :estimated_time
      t.datetime :estimated_end_at

      t.timestamps null: false
    end
  end
end
