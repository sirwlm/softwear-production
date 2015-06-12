class Job < ActiveRecord::Base
  # include CrmCounterpart

  has_one :imprintable_train
  has_many :imprints
  belongs_to :order

  accepts_nested_attributes_for :imprints, allow_destroy: true

  # TODO this will become a thing again at somepoint, I'm sure.
  validates :imprintable_train, presence: true

  before_validation :assign_imprintable_train

  private

  def assign_imprintable_train
    self.imprintable_train = ImprintableTrain.new(state: 'ready_to_order')
  end
end
