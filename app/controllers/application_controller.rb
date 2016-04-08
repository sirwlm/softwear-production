class ApplicationController < ActionController::Base
  include Softwear::Lib::ControllerAuthentication

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :populate_machines
  before_filter :authenticate_user!
  before_filter :assign_current_user
  add_flash_types :error

  helper Softwear::Auth::Helper
  helper_method :xeditable?

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, alert: exception.message
  end

  def populate_machines
    @machines ||= Machine.all
  end

  def configure_user_parameters
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit :email, :password, :password_confirmation, :first_name, :last_name, :default_view
    end
  end

  def assign_fluid_container
    @container_type = 'fluid'
  end

  def assign_current_user
    @current_user = current_user
  end

  def xeditable?(*a)
    true
  end
  
end
