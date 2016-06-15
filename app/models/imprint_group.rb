class ImprintGroup < ActiveRecord::Base
  include CrmCounterpart
  include ColorUtils
  include PublicActivity::Model
  include Schedulable
  include Metricable

  self.crm_class = Crm::ArtworkRequest

  tracked only: [:transition]

  belongs_to :order
  has_many :imprints, inverse_of: :imprint_group
  has_many :imprintable_trains, through: :imprints
  belongs_to :rescheduled_from, class_name: 'ImprintGroup', inverse_of: :reschedules
  has_many :reschedules, class_name: 'ImprintGroup', foreign_key: 'rescheduled_from_id', inverse_of: :rescheduled_from
  belongs_to :machine

  validate :no_circular_reference
  validate :scheduling_cannot_be_changed, if: :print_has_started?

  after_save :mark_original_rescheduled, if: :just_scheduled?
  after_create :set_order_has_imprint_groups_flag
  before_destroy :remove_imprints

  searchable do
    time :scheduled_at
    time :completed_at
    boolean :scheduled do
      !scheduled_at.nil?
    end
    integer :machine_id
    integer :completed_by_id
    integer :order_id
  end

  def respond_to?(*args)
    return super if imprints.empty?
    super || imprints.first.respond_to?(*args)
  end

  def method_missing(name, *args, &block)
    return super if imprints.empty?
    imprints.first.send(name, *args, &block)
  end

  class << self
    def respond_to?(*args)
      super || Imprint.respond_to?(*args)
    end
    def method_missing(name, *args, &block)
      Imprint.send(name, *args, &block)
    end
    def train_public_activity_blacklist
      []
    end
  end

  def full_name(join_char = ', ')
    if name.blank?
      "#{order_deadline_day} #{order.full_name}: Group including #{imprint_names.join(join_char)} (#{count})"
    else
      "#{order_deadline_day} #{order.full_name} - Group #{name} (#{count})"
    end
  end

  def display(join_char = ', ')
    disp = []
    if rescheduled_from_id.present?
      disp << "(RESCHEDULE)"
    elsif reschedules.any?
      disp << "(RESCHEDULED)"
    elsif complete?
      disp << "(COMPLETE)"
    end
    disp << full_name(join_char)
    disp.join(' ')
  end

  def imprintable_train
    imprintable_trains.first
  end

  def generate_rescheduled_group
    new_imprint_group = dup
    new_imprint_group.rescheduled_from_id = rescheduled_from_id || id
    new_imprint_group.scheduled_at = nil
    new_imprint_group.completed_at = nil
    new_imprint_group.completed_by_id = nil

    new_imprint_group.save!
    new_imprint_group.imprints = imprints.map { |i| i.generate_rescheduled_imprint(false) }
    new_imprint_group
  end

  # This is used for dispaying proofs
  # (even though any imprint group should only have one proof on it)
  def unique_crm_imprint_ids
    imprints.pluck(:softwear_crm_id).compact.uniq
  end

  def event_target
    imprints.first
  end

  def calendar_color
    return 'rgb(58, 135, 173)' if machine.blank?
    return 'rgb(204, 204, 204)' if complete?

    machine.color
  end

  def border_color
    return 'white'
  end

  def imprint_names
    imprints.map { |i| "'#{i.job_name} #{i.name}'" }
  end

  def remove_imprints
    Imprint.where(imprint_group_id: id).update_all(imprint_group_id: nil)
  end

  def description
    imprints.pluck(:description).join(', ')
  end

  def count
    quantity || imprints.pluck(:count).reduce(0, :+)
  end

  def type
    imprints.pluck(:type).first || 'Empty'
  end

  def populate_fields_from_imprint(imprint)
    return if imprints.size > 1

    %w(machine_id estimated_time require_manager_signoff).each do |field|
      send("#{field}=", imprint.send(field)) if send(field).nil?
    end
  end

  def order_deadline_day
    self.order.deadline.strftime('%a %m/%d') rescue 'No Deadline'
  end

  def completed_by
    return super unless completed_by_id.nil?
    return nil if completed_at.nil?
    update_column(:completed_by_id, get_completed_by_id_from_activities)
    super
  end

  def started_at
    update_column(:started_at, get_started_at_from_activity) if read_attribute(:started_at).blank?
    read_attribute(:started_at)
  end

  def actual_time
    (completed_at - started_at)/60.0
  end

  def print_has_started?
    if imprints.any?
      %i(pending_rescheduling rescheduled complete printing).include? imprints.first.state.to_sym
    end
  end

  def mark_original_rescheduled
    if rescheduled_from_id.blank?
      return
    elsif rescheduled_from.blank?
      raise "Imprint Group ##{id}'s `rescheduled_from` no longer exists"
    end

    rescheduled_from.imprints.each { |i| i.update_column :state, :rescheduled }
    rescheduled_from.create_activity(
      action:     :transition,
      parameters: { event: 'rescheduled' }
    )
  end

  private

  def no_circular_reference
    if rescheduled_from_id.present? && rescheduled_from_id == id
      errors.add(:rescheduled_from_id, "cannot be self")
    end
  end

  def get_completed_by_id_from_activities
    completion_activity.owner_id rescue nil
  end

  def set_order_has_imprint_groups_flag
    if order && !order.has_imprint_groups
      order.update_column :has_imprint_groups, true
    end
  end
end
