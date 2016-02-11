class AddCreatedByToShipmentTrains < ActiveRecord::Migration
  def change
    add_column :shipment_trains, :created_by_id, :integer
  end
end
