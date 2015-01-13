class Imprint < ActiveRecord::Base
  # include CrmCounterpart

  before_save :assign_estimated_end_at

  scope :scheduled, -> { where.not(scheduled_at: :blank?) }
  scope :unscheduled, -> { where(scheduled_at: nil) }

  belongs_to :machine

  validates :machine, presence: { message: 'must be selected in order to schedule a print',  allow_blank: false }, if: :scheduled?
  validate :schedule_conflict?

  def scheduled?
    !scheduled_at.blank?
  end

  def estimated?
    estimated_time && estimated_time > 0
  end

  def machine_name
    machine.name rescue 'Not Assigned'
  end

  def deadline
    # TODO This should be crm_imprint.order.in_hand_by or something.
    Time.now + (1..10).sample.days
  end

  private

  def schedule_conflict?

  end

  def assign_estimated_end_at
    self.estimated_end_at = (scheduled_at + estimated_time.hours rescue nil)
  end

end
