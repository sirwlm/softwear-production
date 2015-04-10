class CreateScreens < ActiveRecord::Migration
  def change
    create_table :screens do |t|
      t.string :frame_type, index: true
      t.string :dimensions, index: true
      t.string :mesh_type, index: true
      t.string :state, index: true
      t.datetime :deleted_at, index: true
      t.timestamps
    end
  end
end
