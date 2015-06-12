class Order < ActiveRecord::Base
  # include CrmCounterpart
  has_many :jobs

  accepts_nested_attributes_for :jobs
end
