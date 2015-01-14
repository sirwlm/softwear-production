class ImprintsController < InheritedResources::Base
  respond_to :json, :js, :html
  before_filter :prepare_calendar_entries, only: [:index]

  def show
    show! do |format|
      format.js { render layout: nil }
    end
  end

  def update
    update! do |format|
      format.json do
        if params[:machine_id].nil? && params[:scheduled_at].nil? &&
           @imprint.machine_id.nil? && @imprint.scheduled_at.nil?
          partial = 'imprints/unscheduled_entry'
        else
          partial = 'imprints/for_calendar'
        end
        render partial: partial, locals: { imprint: @imprint }
      end
    end
  end

  private

  def prepare_calendar_entries
    if params[:start] && params[:end]
      @calendar_entries = Imprint.scheduled.where('scheduled_at > ? and scheduled_at < ?', params[:start], params[:end])
    end
  end

  def imprint_params
    params.require(:imprint).permit(:name, :description, :estimated_time, :scheduled_at, :machine_id)
  end
end
