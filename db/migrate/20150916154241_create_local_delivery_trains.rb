class CreateLocalDeliveryTrains < ActiveRecord::Migration
  def change
    create_table :local_delivery_trains do |t|
      t.string :state, index: true
      t.integer :delivered_by_id, index: true
      t.string :delivered_to_name
      t.integer :order_id, index: true
      t.timestamps null: false
    end
  end
end
