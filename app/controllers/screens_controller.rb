class ScreensController < InheritedResources::Base
  custom_actions :resource => :transition

  def status
    @screens = Screen.all.select('*, count(*) as count').group(:frame_type, :dimensions, :mesh_type, :state)
  end

  def lookup
    if Screen.exists?(params[:id])
     @screen = Screen.find(params[:id])
    end
  end

  def transition
    @screen = Screen.find(params[:id])
    @screen.send(params[:transition])
    respond_to do |format|
      format.js
    end
  end

  private

  def screen_params
    params.require(:screen).permit(:frame_type, :dimensions, :state, :mesh_type)
  end

end
