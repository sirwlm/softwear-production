class CreateStoreDeliveryTrains < ActiveRecord::Migration
  def change
    create_table :store_delivery_trains do |t|
      t.string :state, index: true
      t.integer :delivered_by_id, index: true
      t.string :store_name, index: true
      t.integer :order_id, index: true
      t.timestamps null: false
    end
  end
end
