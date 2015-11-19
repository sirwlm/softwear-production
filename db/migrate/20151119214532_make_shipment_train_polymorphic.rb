class MakeShipmentTrainPolymorphic < ActiveRecord::Migration
  def change
    add_column :shipment_trains, :shipment_holder_id, :integer
    add_column :shipment_trains, :shipment_holder_type, :string
    ShipmentTrain.unscoped.where.not(order_id: nil).find_each do |train|
      train.update_columns(
        shipment_holder_id:   train.order_id,
        shipment_holder_type: 'Order'
      )
    end
    remove_column :shipment_trains, :order_id, :integer
  end
end
