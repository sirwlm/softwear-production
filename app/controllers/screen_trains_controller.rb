class ScreenTrainsController < InheritedResources::Base
  respond_to :json, only: [:edit, :update]

  def index
    assign_fluid_container
    @screen_trains = ScreenTrain.page(params[:page])
  end

  def edit 
    edit! do |format|
      format.js
    end
  end

  def update 
    update! do |format|
      format.js
    end
  end

  private

  def screen_train_params
    params.require(:screen_train).permit(
      :due_at, :new_separation, :print_type, 
      :artwork_location, :garment_material, 
      :garment_weight, imprint_ids: []

#      jobs_attributes: [
#        :name, :softwear_crm_id,
#
#        imprints_attributes: [
#          :softwear_crm_id, :name, :description, :type,
#          :count
#        ],
#        imprintable_train_attributes: [
#          :state
#        ]
#      ]
    )
  end
end
