class ImprintsController < InheritedResources::Base

  private

  def imprint_params
    params.require(:imprint).permit(:estimated_time, :scheduled_at, :machine_id)
  end
end
