class ImprintsController < InheritedResources::Base
  belongs_to :job, optional: true
  respond_to :json, :js, :html
  before_filter :prepare_calendar_entries, only: [:index]

  def index
    if params[:q]
      search = Imprint.search do
        fulltext params[:q][:text] unless params[:q][:text].blank?
        with(:scheduled_at).greater_than(params[:q][:scheduled_start_at_after]) unless params[:q][:scheduled_start_at_after].blank?
        with(:scheduled_at).less_than(params[:q][:scheduled_start_at_before]) unless params[:q][:scheduled_start_at_before].blank?
        with(:complete, params[:q][:complete] == 'true') unless params[:q][:complete].blank?
        with(:scheduled, params[:q][:scheduled] == 'true') unless params[:q][:scheduled].blank?
      end
      @imprints = search.results
    else
      @imprints = Imprint.search do
        with :complete, false
        paginate page: (params[:page] || 1)
      end
        .results
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
    if params.key?(:user_id)
      @imprint.completed_by_id = params[:user_id]
    else
      @imprint.completed_by = current_user
    end
    @imprint.save!

    show_result
  end

  def transition
    @imprint = Imprint.find(params[:id])
    if params[:user_id]
      @imprint.completed_at = Time.now
      @imprint.completed_by_id = params[:user_id]
    end
    @imprint.fire_state_event(params[:transition])
    @imprint.create_activity(action: :transition, parameters: transition_parameters, owner: owner)
    @imprint.save!
    flash[:notice] = ' Updated Imprint State'
  end

  private

  def transition_parameters
    { event: params[:transition] }
  end

  def owner
    @owner ||= params[:user_id] ? User.find(params[:user_id]) : current_user
  end

  def show_result
    respond_to do |format|
      format.html do
        redirect_to action: :show
      end
      format.js do
        render :show, locals: { refresh_imprint: true }
      end
    end
  end

  def prepare_calendar_entries
    if params[:start] && params[:end]
      @calendar_entries = Imprint.scheduled.where('scheduled_at > ? and scheduled_at < ?', params[:start], params[:end])
      if params[:machine]
        @calendar_entries = @calendar_entries.where(machine_id: params[:machine])

      elsif session[:show_machines] && session[:show_machines].respond_to?(:keys)
        @calendar_entries = @calendar_entries.where(machine_id: session[:show_machines].keys)
      end
    end
  end

  def imprint_params
    params.require(:imprint).permit(:name, :description, :estimated_time, :scheduled_at, :machine_id, :completed_at, :type, :count)
  end

  def complete_params
    params.permit(:user_id)
  end
end
