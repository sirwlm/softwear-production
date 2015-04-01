class Imprint < ActiveRecord::Base
  # include CrmCounterpart

  before_save :assign_estimated_end_at

  scope :scheduled, -> { where.not(scheduled_at: nil).where.not(scheduled_at: '') }
  scope :unscheduled, -> { where(scheduled_at: nil) }
  scope :machineless, -> { where(machine_id: nil) }
  scope :ready_to_schedule, -> { where(scheduled_at: nil).where.not(estimated_time: nil) }

  belongs_to :machine
  belongs_to :completed_by, class_name: 'User'

  validates :machine, presence: { message: 'must be selected in order to schedule a print',  allow_blank: false }, if: :scheduled?
  validate :schedule_conflict?
  validates :name, :description, presence: true

  searchable do
    text :name, :description
    integer :completed_by_id
    boolean :complete  do
      completed?
    end
    time :scheduled_at
    time :completed_at
  end

  def display
    completed? ? "(COMPLETE) #{name}" : name
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

  def complete!(user)
    self.completed_at = Time.now
    self.completed_by = user
    save!
  end

  def machine_name
    machine.name rescue 'Not Assigned'
  end

  def deadline
    # TODO This should be crm_imprint.order.in_hand_by or something.
    Time.now + (1..10).sample.days
  end

  def calendar_color
    if machine.blank?
      'rgb(58, 135, 173)'
    else
      machine.color
    end
  end

  private

  def schedule_conflict?

  end

  def assign_estimated_end_at
    self.estimated_end_at = (scheduled_at + estimated_time.hours rescue nil)
  end

end
