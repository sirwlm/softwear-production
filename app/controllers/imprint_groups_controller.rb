class ImprintGroupsController < InheritedResources::Base
  include CalendarEventController

  belongs_to :order, optional: true
  before_filter :fetch_imprints, only: [:destroy]

  def create
    create! do |format|
      format.js { render }
    end
  end

  def update
    return super if params[:event]

    update! do |format|
      format.js { render }
    end
  end

  def destroy
    destroy! do |format|
      format.js { render }
    end
  end

  def edit
    edit! do |format|
      format.js { render }
    end
  end

  def show
    show! do |format|
      @imprint = @imprint_group
      format.js do
        render template: 'imprints/show'
      end
      format.html do
        render template: 'imprints/show'
      end
    end
  end

  # NOTE this is largely a copy/paste from ImprintsController
  def transition
    @imprint_group = ImprintGroup.find(params[:id])
    @ref_imprint = @imprint_group.imprints.first

    if params[:transition] == 'printing_complete'
      if params[:user_id]
        @ref_imprint.completed_at    = Time.now
        @ref_imprint.completed_by_id = params[:user_id]
        @imprint_group.completed_at    = @ref_imprint.completed_at
        @imprint_group.completed_by_id = @ref_imprint.completed_by_id

        @ref_imprint.fire_state_event(params[:transition])
        @imprint_group.create_activity(action: :transition, parameters: transition_parameters, owner: owner)
        @ref_imprint.save!
        @imprint_group.save!
        flash[:notice] = 'Updated Imprint State'
      else
        flash[:error] = 'Must select user to complete printing'
      end

    elsif params[:transition] == 'production_manager_approved'
      if valid_manager(params[:manager_id], params[:manager_password])
        @ref_imprint.fire_state_event(params[:transition])
        @imprint_group.create_activity(action: :transition, parameters: transition_parameters, owner: owner)
      else
        @imprint_group.create_activity(action: :transition, parameters: transition_parameters, owner: owner)
      end

    else
      @ref_imprint.fire_state_event(params[:transition])
      @imprint_group.create_activity(action: :transition, parameters: transition_parameters, owner: owner)
      @ref_imprint.save!
      flash[:notice] = ' Updated Imprint State'
    end

    @imprint_group.imprints
      .where.not(id: @ref_imprint.id)
      .update_all(
        completed_at:    @ref_imprint.completed_at,
        completed_by_id: @ref_imprint.completed_by_id,
        state:           @ref_imprint.state
      )
    @imprint = @imprint_group # For imprints/transition.js.erb

    render template: 'imprints/transition'
  end

  private

  # NOTE Another copy/paste from ImprintsController
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

  def fetch_imprints
    @imprints = Imprint.where(imprint_group_id: params[:id]).to_a
  end

  def permitted_params
    params.permit(
      imprint_group: calendar_event_params(
        :machine_id, :estimated_time, :require_manager_signoff, :order_id
      )
    )
  end
end
