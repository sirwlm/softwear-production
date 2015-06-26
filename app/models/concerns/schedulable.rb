module Schedulable
  extend ActiveSupport::Concern

  included do
    scope :scheduled, -> { where.not(scheduled_at: nil).where.not(scheduled_at: '') }
    scope :unscheduled, -> { where(scheduled_at: nil) }
    scope :machineless, -> { where(machine_id: nil) }
    scope :ready_to_schedule, -> { where(scheduled_at: nil).where.not(estimated_time: nil) }

    belongs_to :machine
    belongs_to :completed_by, class_name: 'User'

    before_save :assign_estimated_end_at
  end


  def scheduled?
    !scheduled_at.blank?
  end

  def estimated?
    estimated_time && estimated_time > 0
  end

  def completed?
    !completed_at.nil?
  end

  def assign_estimated_end_at
    self.estimated_end_at = (scheduled_at + estimated_time.hours rescue nil)
  end

  def calendar_color
    return 'white'
  end

  def text_color
    'black'
  end

  def border_color
    return 'black'
  end
end
