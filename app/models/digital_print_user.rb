class DigitalPrintUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :digital_print
end
