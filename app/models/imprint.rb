class Imprint < ActiveRecord::Base
  # Scopes
  scope :scheduled, where.not( scheduled_at: :blank? )

  # Constants

  # attr macros

  # followed by association macros
  belongs_to :machine

  # validation macros
  validates :machine, presence: { message: 'must be selected in order to schedule a print',  allow_blank: false }, if: :scheduled?
  validate :schedule_conflict?

  # callbacks
  before_save :assign_estimated_end_at

  # other macros (like devise's)

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
