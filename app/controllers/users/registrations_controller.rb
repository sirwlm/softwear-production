class Users::RegistrationsController < Devise::RegistrationsController
  def create
    super do |resource|
      resource.confirm!
    end
  end

  def index
    @users = User.where.not(id: current_user.id)
  end
end
