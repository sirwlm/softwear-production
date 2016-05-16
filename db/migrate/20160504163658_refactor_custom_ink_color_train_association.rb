class RefactorCustomInkColorTrainAssociation < ActiveRecord::Migration
  def up
    add_column :custom_ink_color_trains, :order_id, :integer

    CustomInkColorTrain.all.each do |ct|
      ct.update_column :order_id, Job.find_by(id: ct[:job_id]).try(:order_id)
    end

    remove_column :custom_ink_color_trains, :job_id, :integer
  end

  def down
    rename_column :custom_ink_color_trains, :order_id, :job_id
  end
end
