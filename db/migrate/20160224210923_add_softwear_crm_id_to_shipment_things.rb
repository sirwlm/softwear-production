class AddSoftwearCrmIdToShipmentThings < ActiveRecord::Migration
  def change
    add_column :shipment_trains,       :softwear_crm_id, :integer
    add_column :local_delivery_trains, :softwear_crm_id, :integer
  end
end
