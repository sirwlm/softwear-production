class MaintenancesController < InheritedResources::Base
  include CalendarEventController

  respond_to :json, :js, :html

  def index
    @maintenances = Maintenance.search do
      paginate page: (params[:page] || 1)
    end
      .results
  end

  def show
    show! do |format|
      format.js { render layout: nil }
      format.html
    end
  end

  def complete
    @maintenance = Maintenance.find(params[:id])
    @maintenance.completed_at = Time.now
    if params.key?(:user_id)
      @maintenance.completed_by_id = params[:user_id]
    else
      @maintenance.completed_by = current_user
    end
    @maintenance.save!

    show_result
  end

  private

  def show_result
    respond_to do |format|
      format.html do
        redirect_to action: :show
      end
      format.js do
        render :show, refresh_maintenance: true
      end
    end
  end

  def maintenance_params
    params.require(:maintenance).permit(:name, :description, :estimated_time, :scheduled_at, :machine_id, :completed_at)
  end
end
