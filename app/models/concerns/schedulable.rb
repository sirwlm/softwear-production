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
      context.where(scheduled_at: nil).where(imprint_group_id: nil)
    else
      context.where(scheduled_at: nil)
    end
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
      context.where(scheduled_at: nil).where.not(estimated_time: nil).where(imprint_group_id: nil)
    else
      context.where(scheduled_at: nil).where.not(estimated_time: nil)
    end
  end

  included do
    Schedulable.schedulable_classes.delete_if { |c| c.name == name }
    Schedulable.schedulable_classes << self

    scope :scheduled, -> { Schedulable.scheduled_scope(self) }
    scope :unscheduled, -> { Schedulable.unscheduled_scope(self) }
    scope :machineless, -> { Schedulable.machineless_scope(self) }
    scope :ready_to_schedule, -> { Schedulable.ready_to_schedule_scope(self) }

    belongs_to :machine
    belongs_to :completed_by, class_name: 'User'

    before_save :assign_estimated_end_at
  end

  def display
    try(:name) || 'Unknown event'
  end

  def event_id
    "#{self.class.table_name.singularize}-#{id}"
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

  def production_deadline
    @production_deadline ||= begin
      if respond_to?(:deadline)
        in_hand_by = deadline
      elsif job_ok = respond_to?(:job) && !job.nil?
        in_hand_by = job.order.try(:deadline)
      elsif order_ok = respond_to?(:order) && !order.nil?
        in_hand_by = order.deadline
      end
      return if in_hand_by.nil?

      if respond_to?(:shipment_train) && !shipment_train.nil?
        offset = shipment_train.time_in_transit
      elsif job_ok
        offset = job.shipment_train.try(:time_in_transit)
        if offset.nil?
          offset = job.order.try(:shipment_train).try(:time_in_transit)
        end
      elsif order_ok
        offset = order.shipment_train.time_in_transit
      end
      return in_hand_by if offset.nil?

      in_hand_by - offset.days
    end
  end
end
