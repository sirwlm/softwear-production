class ImprintableTrain < ActiveRecord::Base
  attr_accessor :solution

  belongs_to :job

end
