class Order < ActiveRecord::Base
  # include CrmCounterpart
  has_many :jobs
  
  validates :name, :jobs,  presence: true

  accepts_nested_attributes_for :jobs, allow_destroy: true
end
