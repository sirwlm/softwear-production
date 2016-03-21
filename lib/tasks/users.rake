namespace :users do
  task eliminate_evil: :environment do |t, args|
    user_id_fields = {"Imprint"=>["completed_by_id"], "ImprintGroup"=>["completed_by_id"], "FbaBaggingTrain"=>["completed_by_id"], "StoreDeliveryTrain"=>[:delivered_by_id], "DigitalPrintUser"=>["user_id"], "ScreenTrain"=>[:assigned_to_id], "EmbroideryPrint"=>["completed_by_id"], "Print"=>["completed_by_id"], "TransferMakingPrint"=>["completed_by_id"], "EquipmentCleaningPrint"=>["completed_by_id"], "ScreenPrint"=>["completed_by_id"], "TransferPrint"=>["completed_by_id"], "DigitalPrint"=>["completed_by_id"], "ButtonMakingPrint"=>["completed_by_id"]}

    id_mapping = {
      61 => 37,
      18 => 49,
      5  => 6,
      75 => 74,
      62 => 63,
      78 => 51,
      66 => 26,
      54 => 65,
      3  => 2
    }

    user_id_fields.each do |class_name, fields|
      model = class_name.constantize

      fields.each do |field|
        id_mapping.each do |from, to|
          model.where(field => from).update_all(field => to)
        end
      end
    end
  end
end
