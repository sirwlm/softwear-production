module Schedulable
  extend ActiveSupport::Concern

  def self.schedulable_classes
    Thread.main[:schedulable_classes] ||= []
  end
  def self.schedulable_classes=(value)
    Thread.main[:schedulable_classes] = value
  end

  %i(scheduled unscheduled machineless ready_to_schedule).each do |scope|
    define_singleton_method "all_#{scope}" do |&block|
      schedulable_classes.flat_map do |c|
        (block ? block.call(c) : c).send(scope)
      end
    end
  end

  def self.scheduled_scope(context)
    if context.method_defined?(:imprint_group_id)
      context.where.not(scheduled_at: nil).where.not(scheduled_at: '').where(imprint_group: nil)
    else
      context.where.not(scheduled_at: nil).where.not(scheduled_at: '')
    end
  end

  def self.unscheduled_scope(context)
    if context.method_defined?(:imprint_group_id)
      q = context.where(scheduled_at: nil).where(imprint_group_id: nil)
    else
      q = context.where(scheduled_at: nil)
    end
    if context.method_defined?(:state)
      q = q.where.not(state: 'canceled')
    end
    q
  end
  
  def self.machineless_scope(context)
    if context.method_defined?(:imprint_group_id)
      context.where(machine_id: nil).where(imprint_group_id: nil)
    else
      context.where(machine_id: nil)
    end
  end

  def self.ready_to_schedule_scope(context)
    if context.method_defined?(:imprint_group_id)
      q = context.where(scheduled_at: nil).where.not(estimated_time: nil).where(imprint_group_id: nil)
    else
      q = context.where(scheduled_at: nil).where.not(estimated_time: nil)
    end
    if context.method_defined?(:state)
      q = q.where.not(state: 'canceled')
    end
    q
  end

  included do
    include Softwear::Auth::BelongsToUser
    include Deadlines
    Schedulable.schedulable_classes.delete_if { |c| c.name == name }
    Schedulable.schedulable_classes << self

    scope :scheduled, -> { Schedulable.scheduled_scope(self) }
    scope :unscheduled, -> { Schedulable.unscheduled_scope(self) }
    scope :machineless, -> { Schedulable.machineless_scope(self) }
    scope :ready_to_schedule, -> { Schedulable.ready_to_schedule_scope(self) }

    belongs_to :machine
    belongs_to_user_called :completed_by

    before_save :assign_estimated_end_at
  end

  def display
    try(:name) || 'Unknown event'
  end

  def event_id
    "#{self.class.table_name.singularize}-#{id}"
  end

  def just_scheduled?
    scheduled_at_was.nil? && scheduled_at_changed?
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
    color_str contrasting_color calendar_color
  end

  def border_color
    return 'black'
  end

  def machine_name
    machine.try(:name) || 'Not Assigned'
  end

  def mark_completed_at
    if self.respond_to?(:imprint_group) && !self.imprint_group.nil?
      time = Time.now
      imprint_group.update_attribute(:completed_at, time)
      imprint_group.imprints.each do |i|
        i.update_attributes(completed_at: time, state: state)
      end
    else
      update_attribute(:completed_at, Time.now)
    end
  end

  protected

  # Custom validation
  def scheduling_cannot_be_changed
    if scheduled_at_changed? || estimated_time_changed?
      errors.add(
        :scheduled_at,
        "cannot be changed once a print is started "\
        "(instead, you should transition to complete and reschedule)"
      )
    end
  end
end
