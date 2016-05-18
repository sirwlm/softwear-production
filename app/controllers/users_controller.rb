require 'softwear/auth/controller'

class UsersController < Softwear::Auth::Controller
  def sign_out
    User.query_cache.clear
    redirect_to destroy_user_session_path
  end
end
