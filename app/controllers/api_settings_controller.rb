class ApiSettingsController < InheritedResources::Base
  actions :new, :show, :create, :update
  load_and_authorize_resource

  def new
    super do |format|
      format.html { render :edit }
    end
  end

  def show
    redirect_to action: :edit
  end

  def edit
    @api_setting = ApiSetting.friendly.find(params[:id])
  end

  private

  def permitted_params
    params.permit({
      api_setting: [:endpoint, :auth_email, :auth_token, :homepage, :slug]
    })
  end
end
