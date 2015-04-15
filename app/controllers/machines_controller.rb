class MachinesController < InheritedResources::Base

  respond_to :js, :html, only: [:show]
  before_filter :assign_fluid_container, only: [:show]

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

  private

  def machine_params
    params.require(:machine).permit(:name, :color)
  end

end
