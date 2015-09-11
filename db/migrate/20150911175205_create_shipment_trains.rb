class CreateShipmentTrains < ActiveRecord::Migration
  def change
    create_table :shipment_trains do |t|
      t.string :state
      t.integer :shipped_by_id
      t.datetime :shipped_at
      t.string :carrier
      t.string :service
      t.string :tracking
      t.integer :order_id
      t.timestamps null: false
    end
  end
end
