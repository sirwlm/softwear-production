class AddTimeInTransitToShipmentTrains < ActiveRecord::Migration
  def change
    add_column :shipment_trains, :time_in_transit, :decimal, precision: 10, scale: 2
  end
end
