class AddPreviousStateToAllTrains < ActiveRecord::Migration
  def change
    %i(
      ar3_trains custom_ink_color_trains digitization_trains fba_bagging_trains
      fba_label_trains imprintable_trains local_delivery_trains preproduction_notes_trains
      screen_trains shipment_trains stage_for_fba_bagging_trains stage_for_pickup_trains
      store_delivery_trains imprints
    )
    .each do |table|
      add_column table, :previous_state, :string
    end
  end
end
