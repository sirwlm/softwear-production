class CreateStageForPickupTrains < ActiveRecord::Migration
  def change
    create_table :stage_for_pickup_trains do |t|
      t.string :state, index: true
      t.string :location, index: true
      t.integer :order_id, index: true
      t.timestamps null: false
    end
  end
end
