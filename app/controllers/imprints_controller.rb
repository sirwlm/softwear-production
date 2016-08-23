class ImprintsController < InheritedResources::Base
  include CalendarEventController

  belongs_to :job, optional: true
  respond_to :json, :js, :html
  before_filter :prepare_calendar_entries, only: [:index]
  before_filter :grab_imprint_group, only: [:update]
  helper_method :imprint_group

  def index
    return if @calendar_entries

    if params[:q]
      @imprints = Imprint.search do
        fulltext params[:q][:text] unless params[:q][:text].blank?
        with(:scheduled_at).greater_than(params[:q][:scheduled_start_at_after]) unless params[:q][:scheduled_start_at_after].blank?
        with(:scheduled_at).less_than(params[:q][:scheduled_start_at_before]) unless params[:q][:scheduled_start_at_before].blank?
        with(:complete, params[:q][:complete] == 'true') unless params[:q][:complete].blank?
        with(:scheduled, params[:q][:scheduled] == 'true') unless params[:q][:scheduled].blank?
      end
        .results
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

    if params[:transition] == 'printing_complete'
      if params[:user_id]
        @imprint.completed_at = Time.now
        @imprint.completed_by_id = params[:user_id]
        @imprint.fire_state_event(params[:transition])
        @imprint.create_activity(action: :transition, parameters: transition_parameters, owner: owner)
        @imprint.save!
        flash[:notice] = 'Updated Imprint State'
      else
        flash[:error] = 'Must select user to complete printing'
      end

    elsif params[:transition] == 'production_manager_approved'
      if valid_manager(params[:manager_id], params[:manager_password])
        @imprint.fire_state_event(params[:transition])
        @imprint.create_activity(action: :transition, parameters: transition_parameters, owner: owner)
      else
        @imprint.create_activity(action: :transition, parameters: transition_parameters, owner: owner)
      end

    else
      @imprint.fire_state_event(params[:transition])
      @imprint.create_activity(action: :transition, parameters: transition_parameters, owner: owner)
      @imprint.save!
      flash[:notice] = ' Updated Imprint State'
    end

  end

  def confirm_imprint_data
    @imprint = params[:imprint_or_group].constantize.find(params[:id])
    if request.post?
      @imprint.confirmed_print_time = imprint_params[:confirmed_print_time].to_i * 60
      @imprint.confirmed_setup_time = imprint_params[:confirmed_setup_time].to_i * 60
      @imprint.confirm_data
      @imprint.save
    end
  end

  # NOTE the imprint IDs managed in this action is a CRM imprint.
  def proof_info
    param = params[:id]

    if param =~ /\A\[/ # if param starts with '[', it is a ruby array of integers, which can be interpreted as JSON.
      @imprints = JSON.parse(param).map { |id| Crm::Imprint.find(id) }
    else
      @imprints = [Crm::Imprint.find(param)]
    end
  end

  private

  def valid_manager(id, password)
    user = User.find_by(id: id)
    flash[:error] = "Invalid Manager Password" unless user.valid_password?(password)
    user.valid_password?(password)
  end

  def transition_parameters
    t_p = { event: params[:transition] }
    t_p[:printed_by] = params[:user_id] unless params[:user_id].nil?
    t_p[:approved_by] = params[:manager_id] unless params[:manager_id].nil?
    t_p[:invalid_password_attempt] = "bad manager password" unless params[:manager_id] && valid_manager(params[:manager_id], params[:manager_password])
    t_p
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

      elsif current_user.shown_machines.any?
        @calendar_entries = @calendar_entries.where(machine_id: current_user.shown_machines.pluck(:machine_id))
      end
    end
  end

  def imprint_params
    Imprint.descendants.each do |print_type|
      key = print_type.name.underscore

      if params[key]
        params[:imprint] = params[key]
        break
      end
    end

    params.require(:imprint).permit(
      :name, :description, :estimated_time, :scheduled_at, :machine_id, :completed_at, :job_id,
      :type, :count, :require_manager_signoff, :imprint_group_id, :softwear_crm_id, :revolved,
      :confirmed_print_time, :confirmed_setup_time
    )
  end

  def complete_params
    params.permit(:user_id)
  end

  def grab_imprint_group
    return unless params.key?(:id)
    group_id = Imprint.where(id: params[:id]).pluck(:imprint_group_id).first
    @imprint_group = ImprintGroup.find(group_id) unless group_id.nil?
  end

  def imprint_group
    @imprint_group || @imprint.imprint_group
  end
end
