class UserRole < ActiveRecord::Base
  include Softwear::Auth::BelongsToUser

  belongs_to_user
  belongs_to :role
end
