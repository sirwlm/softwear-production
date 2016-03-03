class DigitalPrintUser < ActiveRecord::Base
  include Softwear::Auth::BelongsToUser

  belongs_to_user
  belongs_to :digital_print
end
