class ApiSettingsController < InheritedResources::Base
  actions :new, :edit, :create, :update

  def new
    super do |format|
      format.html { render :edit }
    end
  end
end