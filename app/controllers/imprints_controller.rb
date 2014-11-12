class ImprintsController < InheritedResources::Base
  respond_to :json, :js, :html

  def show
    show! do |format|
      format.js { render layout: nil }
    end
  end

  private

  def imprint_params
    params.require(:imprint).permit(:estimated_time, :scheduled_at, :machine_id)
  end
end
