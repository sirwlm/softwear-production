class ScreenTrainsController < InheritedResources::Base
  respond_to :json, only: [:edit, :update]

  def edit
    edit! do |format|
      format.js
    end
  end

  def update 
    update! do |success, failure|
      success.js do
        @object = @screen_train
        @title  = "Screen train (updated)"
        render 'screen_trains/update'
      end
      failure.js { render 'screen_trains/edit' }
    end
  end

  private

  def screen_train_params
    params.require(:screen_train).permit(
      :due_at, :new_separation, :print_type, :notes, 
      :artwork_location, :garment_material, :assigned_to_id, 
      :garment_weight, :lpi, imprint_ids: [],
      screen_requests_attributes: [
        :frame_type, :mesh_type, :dimensions, 
        :ink, :primary, :screen_train_id, :id, :_destroy
      ],
      assigned_screens_attributes: [
        :screen_request_id, :_destroy, :id, :screen_id, 
        :double_position
      ]
    )
  end
end
