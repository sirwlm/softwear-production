class CreateScreenRequests < ActiveRecord::Migration
  def change
    create_table :screen_requests do |t|
      t.integer :screen_train_id, index: true
      t.string :frame_type, index: true
      t.string :mesh_type, index: true
      t.string :dimensions, index: true
      t.string :ink, index: true
      t.string :lpi, index: true
      t.boolean :primary, index: true 
      t.timestamps null: false
    end
  end
end
