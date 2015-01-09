class Job < ActiveRecord::Base
  # include CrmCounterpart

  has_one :imprintable_train

  validates :imprintable_train, presence: true

  before_validation :assign_imprintable_train

private

  def assign_imprintable_train
    self.imprintable_train = ImprintableTrain.new
    false unless self.imprintable_train.save
  end
end
