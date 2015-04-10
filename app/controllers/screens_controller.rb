class ScreensController < InheritedResources::Base
  custom_actions :resource => :transition

  def status
    load_screens_grouped_by_type
  end

  def lookup
    if Screen.exists?(params[:id])
     @screen = Screen.find(params[:id])
    end
  end

  def transition
    @screen = Screen.find(params[:id])
    @screen.send(params[:transition])|
    @screen.create_activity(action: :transition, parameters: transition_parameters, owner: owner)
    flash[:notice] = ' Updated Screen State'
    load_screens_grouped_by_type
    respond_to do |format|
      format.js
    end
  end

  private

  def load_screens_grouped_by_type
    @screens = Screen.all.select('*, count(*) as count').group(:frame_type, :dimensions, :mesh_type, :state)
  end

  def screen_params
    params.require(:screen).permit(:frame_type, :dimensions, :state, :mesh_type)
  end

  def owner
    current_user unless params[:user_id]
    User.find(params[:user_id]) if params[:user_id]
  end

  def transition_parameters
    parameters = { event: params[:transition] }
    parameters[:reason] = params[:reason] unless params[:reason].nil?
    parameters
  end

end
