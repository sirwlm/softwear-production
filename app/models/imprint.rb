class Imprint < ActiveRecord::Base
  # include CrmCounterpart
  include ColorUtils
  include PublicActivity::Model
  include Schedulable

  tracked only: [:transition]

  before_save :reset_state_when_type_changed

  belongs_to :job

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
    boolean :scheduled do
      !scheduled_at.nil?
    end
  end

  def approved?
    state.to_sym != :pending_approval
  end

  def display
    return "(UNAPPROVED) #{name}" unless approved?
    return "(COMPLETE) #{name}" if completed?
    name
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
    return 'white' if !approved?
    return 'rgb(58, 135, 173)' if machine.blank?
    return 'rgb(204, 204, 204)' if completed?

    machine.color
  end

  def text_color
    unless machine.blank?
      return machine.color if completed? || !approved?
    end

    if intensity(calendar_color) > 300
      'black'
    else
      'white'
    end
  end

  def border_color
    if !approved? || completed?
      return 'black'
    end

    color = calendar_color

    if intensity(color) > 382
      factor = 0.2
    else
      factor = 0.75
    end

    "rgb(#{rgb(color).map { |c| [255, c * factor].min.floor }.join(', ')})"
  end

  private

  def schedule_conflict?

  end

  def reset_state_when_type_changed
    if type_changed?
      self.state = :pending_approval
    end
  end

end
