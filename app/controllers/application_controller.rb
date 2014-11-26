class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :populate_machines
  before_filter :authenticate_user!
  before_action :configure_user_parameters, if: :devise_controller?
  add_flash_types :error

  def populate_machines
    @machines ||= Machine.all
  end

  def configure_user_parameters
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit :email, :password, :password_confirmation, :first_name, :last_name
    end
  end

end
