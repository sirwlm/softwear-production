class ShownMachine < ActiveRecord::Base
  include Softwear::Auth::BelongsToUser

  belongs_to_user
  belongs_to :machine
end
