class CreateMaintenances < ActiveRecord::Migration
  def change
    create_table :maintenances do |t|
      t.datetime :scheduled_at
      t.datetime :estimated_time
      t.datetime :estimated_end_at
      t.integer :machine_id
      t.datetime :completed_at
      t.integer :completed_by_id
      t.string :name
      t.string :description

      t.timestamps null: false
    end
  end
end
