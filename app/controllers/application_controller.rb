class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :populate_machines
  add_flash_types :error

  def populate_machines
    @machines ||= Machine.all
  end

end
