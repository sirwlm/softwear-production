class ScreenTrainsController < InheritedResources::Base
  respond_to :json, only: [:edit, :update]

  def index
    assign_fluid_container
    q = params[:q]
    @screen_trains = ScreenTrain.search do
      if q
        fulltext q[:text] unless q[:text].blank?  
        with :assigned_to_id, q[:assigned_to_id] unless q[:assigned_to_id].blank?
        with(:due_at).greater_than(q[:due_at_after]) unless q[:due_at_after].blank?
        with(:due_at).less_than(q[:due_at_before])     unless q[:due_at_before].blank?
        with :order_state, q[:order_state] unless q[:order_state].blank?
        with :order_imprint_state, q[:order_imprint_state] unless q[:order_imprint_state].blank?
        order_by :created_at, :desc
      else
        with :complete, false
      end

      paginate page: params[:page] || 1
    end
      .results
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
      :due_at, :new_separation, :print_type, :notes, 
      :artwork_location, :garment_material, :assigned_to_id, 
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
