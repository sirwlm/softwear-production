class Machine < ActiveRecord::Base
  has_many :imprints

  validates :name, presence: true
end
