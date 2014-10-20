class ApiSettingsController < InheritedResources::Base
  actions :new, :show, :create, :update

  def new
    super do |format|
      format.html { render :edit }
    end
  end

  def edit
    @api_setting = ApiSetting.friendly.find(params[:id])
  end

  private

  def permitted_params
    params.permit({
      api_setting: [:endpoint, :auth_token, :homepage, :site_name]
    })
  end
end