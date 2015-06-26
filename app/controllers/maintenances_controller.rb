class MaintenancesController < InheritedResources::Base
  respond_to :json, :js, :html

  def index
    @maintenances = Maintenance.search do
      paginate page: (params[:page] || 1)
    end
      .results
  end

  private

  def maintenance_params
    params.require(:maintenance).permit(:name, :description, :estimated_time, :scheduled_at, :machine_id, :completed_at)
  end
end
