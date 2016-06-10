class ApplicationController < ActionController::Base
  include Softwear::Lib::ControllerAuthentication

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :populate_machines
  before_action :authenticate_user!
  before_action :assign_current_user
  before_action :set_title
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

  def set_title
    @title = ""
    @title += "#{Rails.env.upcase} - " unless Rails.env.production?
    @title += "Production - "
    begin
      # resource segment
      if defined?(resource_class) && (resource rescue nil).nil?
        @title += "#{resource_class.to_s.underscore.humanize.pluralize} - "
      elsif defined?(resource_class) && (resource rescue nil).persisted?
        @title += "#{resource_class.to_s.underscore.humanize} ##{resource.id} - "
      elsif defined?(resource_class) && !(resource rescue nil).persisted?
        @title += "#{resource_class.to_s.underscore.humanize} - "
      end

      unless (resource rescue nil).nil?
        @title += "#{resource.name} - " if resource.respond_to?(:name) && !resource.name.blank?
      end

      @title += "#{action_name.humanize} - " unless (action_name rescue nil).nil?
    rescue Exception => _e
    end

    @title += "SoftWEAR"
    @title
  end
end
