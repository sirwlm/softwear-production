class UsersController < InheritedResources::Base
  load_and_authorize_resource
  check_authorization

  def index
    @users = User.where.not(id: current_user.id)
  end

  def create
    super do |success, failure|
      success.html do
        @user.confirm!
        flash[:notice] = 'New user was successfully created'
        redirect_to users_path
      end
      failure.html do
        flash[:alert] = 'Unable to save your new person'
        render :new
      end
    end
  end

  def update
    super do |success, failure|
      success.html do
        flash[:notice] = 'Successfully updated user.'
        redirect_to users_path
      end

      failure.html do
        flash[:alert] = 'Unable to update user'
        render :edit
      end
    end
  end

private

  def permitted_params
    params.permit(user: [:first_name, :last_name, :email, :admin, :password, :password_confirmation])
  end
end
