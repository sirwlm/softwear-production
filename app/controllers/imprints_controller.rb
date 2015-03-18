class ImprintsController < InheritedResources::Base
  respond_to :json, :js, :html
  before_filter :prepare_calendar_entries, only: [:index]

  def index
    if params[:q]
      search = Imprint.search do
        fulltext params[:q][:text]
        with(:scheduled_at).greater_than(params[:q][:scheduled_start_at_after]) unless params[:q][:scheduled_start_at_after].blank?
        with(:scheduled_at).less_than(params[:q][:scheduled_start_at_before]) unless params[:q][:scheduled_start_at_before].blank?
        with(:complete, params[:q][:complete] == 'true') unless params[:q][:complete].blank?
      end
      @imprints = search.results
    else
      index!
    end
  end


  def show
    show! do |format|
      format.js { render layout: nil }
    end
  end

  def update
    update! do |format|
      format.json do
        if params[:return_content]
          partial = 'imprints/unscheduled_entry'
        else
          partial = 'imprints/for_calendar'
        end
        render partial: partial, locals: { imprint: @imprint }
      end
    end
  end

  def complete
    @imprint = Imprint.find(params[:id])
    @imprint.completed_at = Time.now
    @imprint.completed_by = current_user
    @imprint.save!

    respond_to do |format|
      format.html do
        redirect_to action: :show
      end
      format.js do
        render :show
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

  def complete_params
    params.permit(:user_id)
  end
end
