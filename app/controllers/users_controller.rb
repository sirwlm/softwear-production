require 'softwear/auth/controller'

class UsersController < Softwear::Auth::Controller
  include Softwear::Library::ControllerAuthentication

  def sign_out
    session[:user_token] = nil
    redirect_to destroy_user_session_path
  end
end
