class MachinesController < InheritedResources::Base
  load_and_authorize_resource
  respond_to :json, :js, :html
  before_filter :assign_fluid_container, only: [:show, :agenda]

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
    elsif session[:show_machines] && session[:show_machines].respond_to?(:keys)
      machine_id = session[:show_machines].keys
    else
      @calendar_events = [] and return
    end

    @calendar_events = Sunspot.search(*Schedulable.schedulable_classes) do
      with :scheduled_at, time_start..time_end
      with :machine_id, machine_id if machine_id
      with :canceled, false
      paginate page: 1, per_page: 5000
    end
      .results
  end

  def agenda
    time_start = (params[:date].nil? ? Date.today : Date.parse(params[:date]))
    time_end   = time_start + 1.day

    @machine = Machine.find(params[:machine_id])
    @itineary_events = Sunspot.search(*Schedulable.schedulable_classes) do
      with :scheduled_at, time_start..time_end
      with :machine_id, params[:machine_id] if params[:machine_id]
      order_by :scheduled_at, :asc
      with :canceled, false
      paginate page: 1, per_page: 5000
    end.results
    @date = time_start
  end

  private

  def machine_params
    params.require(:machine).permit(:name, :color)
  end

end
