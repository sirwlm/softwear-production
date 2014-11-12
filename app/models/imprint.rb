class Imprint < ActiveRecord::Base
  before_save :assign_estimated_end_at

  scope :scheduled, -> { where.not( scheduled_at: :blank? ) }

  belongs_to :machine

  validates :machine, presence: { message: 'must be selected in order to schedule a print',  allow_blank: false }, if: :scheduled?
  validate :schedule_conflict?

  def scheduled?
    !scheduled_at.blank?
  end

  def machine_name
    machine.name rescue 'Not Assigned'
  end

  private

  def schedule_conflict?

  end

  def assign_estimated_end_at
    self.estimated_end_at = (scheduled_at + estimated_time.hours rescue nil)
  end

end
