class CreateScreenRequests < ActiveRecord::Migration
  def change
    create_table :screen_requests do |t|
      t.string :frame, index: true
      t.string :mesh, index: true
      t.string :size, index: true
      t.string :ink, index: true
      t.string :lpi, index: true
      t.boolean :primary, index: true 
      t.timestamps null: false
    end
  end
end
