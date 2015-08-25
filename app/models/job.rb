class Job < ActiveRecord::Base
  include CrmCounterpart
  include TrainStation

  has_one :imprintable_train, dependent: :destroy
  has_many :imprints, dependent: :destroy
  belongs_to :order

  validates :imprintable_train,  presence: true

  accepts_nested_attributes_for :imprints, allow_destroy: true

  before_validation :assign_imprintable_train

  def full_name
    "#{order.name} - #{name}" rescue name
  end

  # TODO Remove this override when converting imprints to proper trains
  def production_trains
    (super rescue []) + imprints
  end

  def imprint_state
    if imprints.where(completed_at: nil).size == 0
      'Printed'
    else
      'Pending'
    end
  end

  def production_state
    trains.all?(&:complete?) ? 'Complete' : 'Pending'
  end

  private

  def assign_imprintable_train
    self.imprintable_train ||= ImprintableTrain.new(state: 'ready_to_order')
  end
end
