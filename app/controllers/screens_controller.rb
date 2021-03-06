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
    if Screen.exists?(params[:id])
      @screen = Screen.find(params[:id])
    else
      flash[:alert] = 'Invalid Screen ID'
      return
    end

    if params[:mesh_type] && params[:transition] == 'meshed'
      @screen.update_attribute(:mesh_type, params[:mesh_type])
    end

    if params[:expected_state] && params[:expected_state] != @screen.state
      flash.now[:alert] = "Screen was not in the expected state. You expected screen ##{@screen.id} "\
        "to be in state #{params[:expected_state]} but was in state #{@screen.state}"

    else
      flash.now[:notice] = "Screen state was successfully updated"
      @screen.fire_state_event(params[:transition])
      @screen.create_activity(action: :transition, parameters: transition_parameters, owner: owner)
    end

    load_screens_grouped_by_type

    respond_to do |format|
      format.js
    end
  end

  def force_transition
    @screen = Screen.find(params[:id])
    @original_state = @screen.state
    @new_state      = params[:state]

    @screen.update_column :state, @new_state

    @screen.create_activity(
      action: :fix_state,
      parameters: {
        responsible: params[:responsible],
        state_from:  @original_state,
        state_to:   @new_state
      },
      owner: current_user
    )

    flash[:notice] = "Screen ##{@screen.id}'s state has been adjusted"
    redirect_to action: :fast_scan
  end

  private

  def load_screens_grouped_by_type
    @screens = Screen.all.select('*, count(*) as count').group(:frame_type, :dimensions, :mesh_type, :state)
  end

  def screen_params
    params.require(:screen).permit(:frame_type, :dimensions, :state, :mesh_type, :serial_no, :id)
  end

  def owner
    return current_user unless params[:user_id]
    return User.find(params[:user_id]) if params[:user_id]
  end

  def transition_parameters
    parameters = { event: params[:transition] }
    parameters[:reason] = params[:reason] unless params[:reason].nil?
    parameters[:mesh_type] = params[:mesh_type] unless params[:mesh_type].nil?
    parameters
  end

end
