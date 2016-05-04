class RefactorCustomInkColorTrainAssociation < ActiveRecord::Migration
  def change
    add_column :custom_ink_color_trains, :order_id, :integer
    
    CustomInkColorTrain.all.each do |ct|
      new_order_id = ct.job.nil? ? nil : ct.job.order_id
      ct.order_id = new_order_id

      begin
        ct.save!
      rescue
        puts "Custom Ink Train ##{ct.id} had a problem updating order_id"
      end
    end

    remove_column :custom_ink_color_trains, :job_id, :integer
  end
end
