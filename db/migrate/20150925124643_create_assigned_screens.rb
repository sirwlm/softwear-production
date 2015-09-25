class CreateAssignedScreens < ActiveRecord::Migration
  def change
    create_table :assigned_screens do |t|
      t.integer :screen_request_id, index: true
      t.integer :screen_train_id, index: true
      t.integer :screen_id, index: true
      t.string :double_position, index: true
      t.timestamps null: false
    end
  end
end
