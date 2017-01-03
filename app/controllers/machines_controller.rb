class MachinesController < InheritedResources::Base
  load_and_authorize_resource
  respond_to :json, :js, :html
  before_filter :assign_fluid_container, only: [:show, :agenda]
  before_action :assign_refresh_rate, only: [:show, :agenda, :calendar_events]

  def create
    create! do |success, failure|
      success.html { redirect_to machines_path }
      failure.html { render 'new' }
    end
  end

  def update
    update! do |success, failure|
      success.html { redirect_to machines_path }
      failure.html { render 'edit' }
    end
  end

  def scheduled
    @machine = Machine.find(params[:machine_id])
    respond_to do |format|
      format.json
    end
  end

  def calendar_events
    time_start = Time.parse(params[:start])
    time_end   = Time.parse(params[:end]) + 5.hours
    if params[:machine]
      machine_id = params[:machine]
    elsif current_user.shown_machines.any?
      machine_id = current_user.shown_machines.pluck(:machine_id)
    else
      @calendar_events = [] and return
    end

    @calendar_events = Schedulable.schedulable_classes.flat_map do |c|
      c = c.where(scheduled_at: time_start..time_end)
      c = c.where(machine_id: machine_id) if machine_id
      c.to_a
    end
      .reject { |e| e.canceled? || e.try(:part_of_group?) }
    
    # TODO the sunspot search does not retrieve all schedulables for some reason
=begin
    @calendar_events = Sunspot.search(*Schedulable.schedulable_classes) do
      with :scheduled_at, time_start..time_end
      with :machine_id, machine_id if machine_id
      with :canceled, false
      paginate page: 1, per_page: 5000
    end
      .results
=end
  end

  def agenda
    time_start = (params[:date].blank? ? Date.today : Date.parse(params[:date]))
    time_end   = time_start + 1.day

    @machine = Machine.find(params[:machine_id])

    @itineary_events = Schedulable.schedulable_classes.flat_map do |c|
      c = c.where(scheduled_at: time_start..time_end)
      c = c.where(machine_id: params[:machine_id]) if params[:machine_id]
      c.to_a
    end
      .reject { |e| e.canceled? || e.try(:part_of_group?) }
      .sort_by(&:scheduled_at)

    # TODO the sunspot search does not retrieve all schedulables for some reason
=begin
    @itineary_events = Sunspot.search(*Schedulable.schedulable_classes) do
      with :scheduled_at, time_start..time_end
      with :machine_id, params[:machine_id] if params[:machine_id]
      order_by :scheduled_at, :asc
      with :canceled, false
      paginate page: 1, per_page: 5000
    end.results
=end

    @date = time_start
  end

  private

  def machine_params
    params.require(:machine).permit(:name, :color)
  end

  def assign_refresh_rate
    if Rails.env.development? || Rails.env.test?
      @agenda_refresh_rate = 7500
    else
      @agenda_refresh_rate = 300000
    end
  end
end
