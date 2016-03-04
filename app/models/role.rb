class Role < ActiveRecord::Base
  has_many :user_roles

  def users
    user_roles.pluck(:user_id).map(&User.method(:find))
  end
end
