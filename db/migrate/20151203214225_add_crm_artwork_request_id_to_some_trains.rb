class AddCrmArtworkRequestIdToSomeTrains < ActiveRecord::Migration
  def change
    add_column :digitization_trains, :crm_artwork_request_id, :integer
    add_column :ar3_trains, :crm_artwork_request_id, :integer
    add_column :screen_trains, :crm_artwork_request_id, :integer
  end
end
