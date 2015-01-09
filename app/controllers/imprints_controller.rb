class ImprintsController < InheritedResources::Base
  respond_to :json, :js, :html

  def show
    show! do |format|
      format.js { render layout: nil }
    end
  end

  def update
    update! do |format|
      format.json do
        puts "**********************************"
        puts @imprint.scheduled_at
        puts params[:imprint][:scheduled_at]
        render partial: 'imprints/for_calendar', locals: { imprint: @imprint }
      end
    end
  end

  private

  def imprint_params
    params.require(:imprint).permit(:estimated_time, :scheduled_at, :machine_id)
  end
end
