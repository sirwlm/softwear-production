class Order < ActiveRecord::Base
  # include CrmCounterpart
  has_many :jobs
end
