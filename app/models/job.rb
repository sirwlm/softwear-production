class Job < ActiveRecord::Base
  # include CrmCounterpart
  include TrainStation

  has_one :imprintable_train
  has_many :imprints
  belongs_to :order

  validates :imprintable_train,  presence: true

  accepts_nested_attributes_for :imprints, allow_destroy: true

  before_validation :assign_imprintable_train

  def full_name
    "#{order.name} - #{name}" rescue name
  end

  def production_trains
    (super rescue []) + imprints
  end

  private

  def assign_imprintable_train
    self.imprintable_train ||= ImprintableTrain.new(state: 'ready_to_order')
  end
end
