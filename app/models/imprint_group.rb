class ImprintGroup < ActiveRecord::Base
  belongs_to :order
  has_many :imprints
end
