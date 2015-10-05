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
    update! do |success, failure|
      success.js { render :js => "window.location = '#{screen_trains_path}'" }
      failure.js { render 'screen_trains/edit' }
    end
  end

  private

  def screen_train_params
    params.require(:screen_train).permit(
      :due_at, :new_separation, :print_type, 
      :artwork_location, :garment_material, 
      :garment_weight, imprint_ids: [],
      screen_requests_attributes: [
        :frame_type, :mesh_type, :dimensions, 
        :ink, :lpi, :primary, :screen_train_id, :id, :_destroy
      ],
      assigned_screens_attributes: [
        :screen_request_id, :_destroy, :id, :screen_id, 
        :double_position
      ]
    )
  end
end
