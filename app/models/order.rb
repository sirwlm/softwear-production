class Order < ActiveRecord::Base
  # include CrmCounterpart
  has_many :jobs
  has_many :imprints, through: :jobs

  validates :name, :jobs,  presence: true

  accepts_nested_attributes_for :jobs, allow_destroy: true
end
