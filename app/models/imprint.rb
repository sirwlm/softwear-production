class Imprint < ActiveRecord::Base
  TYPES = [
    "Screen Print", "Embroidery Print", "Digital Print",
    "Button Making Print", "Transfer Making Print", "Transfer Print",
    "Print", "Equipment Cleaning Print"
  ]

  include CrmCounterpart
  include ColorUtils
  include PublicActivity::Model
  include Schedulable
  include Metricable
  include ImprintData

  tracked only: [:transition]

  scope :scheduled, -> { Schedulable.scheduled_scope(self).where(imprint_group_id: nil) }
  scope :unscheduled, -> { Schedulable.unscheduled_scope(self).where(imprint_group_id: nil) }
  scope :machineless, -> { Schedulable.machineless_scope(self).where(imprint_group_id: nil) }
  scope :ready_to_schedule, -> { Schedulable.ready_to_schedule_scope(self).where(imprint_group_id: nil) }

  validates :machine, presence: { message: 'must be selected in order to schedule a print',  allow_blank: false }, if: proc { scheduled? && !part_of_group? }
  validate :schedule_conflict?, unless: :part_of_group?
  validate :type_matches_group, if: :part_of_group?
  validates :name, :description, presence: true
  validates :count, presence: true, numericality: { greater_than: 0 }
  validates :type, presence: true
  validate :no_circular_reference

  before_save :assign_estimated_end_at
  before_save :reset_state_when_type_changed
  before_save :synchronize_with_group, if: :part_of_group?
  before_save :set_completed_at_if_necessary
  after_commit :populate_group_fields
  after_save :mark_original_rescheduled, if: :just_scheduled?

  belongs_to :job
  belongs_to :imprint_group, inverse_of: :imprints
  belongs_to :screen_train
  belongs_to :rescheduled_from, class_name: 'Imprint', inverse_of: :reschedules
  has_many :reschedules, class_name: 'Imprint', foreign_key: 'rescheduled_from_id', inverse_of: :rescheduled_from
  has_many :assigned_screens, through: :screen_train
  has_many :screens, through: :assigned_screens
  has_one :order, through: :job
  has_one :imprintable_train, through: :job

  searchable do
    text :full_name, :description

    integer :completed_by_id
    integer :machine_id
    integer :job_id
    integer :imprint_group_id
    integer :order_id do
      order.id rescue nil
    end

    string :imprint_group_or_imprint_id_str do
      imprint_group_or_imprint_id_str
    end

    boolean :complete  do
      completed?
    end
    boolean :scheduled do
      !scheduled_at.nil?
    end

    time :scheduled_at
    time :completed_at
  end

  def on_complete
    if order.fba?
      fba_train =  order.fba_bagging_train
      fba_train.update_attributes(printed: fba_train.production_trains_complete?)
    end
  end

  def revolved
    super || false
  end

  # This is used for dispaying proofs
  def unique_crm_imprint_ids
    [softwear_crm_id].compact
  end

  def imprint_group_or_imprint_id_str
    imprint_group.nil? ? id.to_s : imprint_group_id.to_s
  end

  def part_of_group?
    !imprint_group_id.nil?
  end

  def approved?
    state.to_sym != :pending_approval
  end

  def display
    disp = []
    disp << "(UNAPPROVED)" unless approved?
    if reschedules.any?
      disp << "(RESCHEDULED x#{reschedules.count})"
    elsif complete?
      disp << "(COMPLETE)"
    end
    disp << "(RESCHEDULE)" if rescheduled_from_id.present?
    disp << full_name
    disp.join(' ')
  end

  def complete!(user)
    self.completed_at = Time.now
    self.completed_by = user
    save!
  end

  def calendar_color
    return 'white' if !approved?
    return 'rgb(58, 135, 173)' if machine.blank?
    return 'rgb(204, 204, 204)' if complete?

    machine.color
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

  def job_name
    if job.blank?
      'n/a'
    else
      self.job.full_name rescue 'n/a'
    end
  end

  def order_name
    self.order.full_name rescue 'n/a'
  end

  def name_with_job
    "Job ##{job.try(:softwear_crm_id) || '?'}: #{name}"
  end

  def full_name
    "#{order_deadline_day} - #{job_name} - #{name} (#{count})"
  end

  def order_deadline_day
    self.order.deadline.strftime('%a %m/%d') rescue 'No Deadline'
  end

  def train_state
    state
  end

  def details
    {
      name:         name,
      description:  description,
      type:         type,
      machine_name: machine.try(:name) || 'unassigned',
      count:        count,
      require_manager_signoff: !require_manager_signoff.nil?
    }
  end

  def serializable_hash(options = {})
    super(
      {
        only: [:state, :id, :created_at, :update, :scheduled_at, :estimated_time, :estimated_end_at],
        methods: [:train_type, :train_class, :state_type, :details, :at_initial_state]
      }
        .merge(options)
    )
  end

  def scheduled?
    part_of_group? ? imprint_group.scheduled? : super
  end

  def completed_by
    return super unless completed_by_id.nil?
    return nil if completed_at.nil?
    update_column(:completed_by_id, get_completed_by_id_from_activities)
    super
  end

  def display_completed_by
    completed_by.try(:full_name) || 'someone'
  end

  def started_at
    update_column(:started_at, get_started_at_from_activity) if read_attribute(:started_at).blank?
    read_attribute(:started_at)
  end

  def get_started_at_from_activity
    start_activity.created_at rescue nil
  end

  def actual_time
    (completed_at - started_at)/60.0
  end

  def activities
    if imprint_group.nil?
      super
    else
      imprint_group.activities
    end
  end

  def machine_name
    machine.name rescue 'Not Assigned'
  end

  # Don't allow setting the name to blank
  def name=(n)
    return if n.blank?
    super
  end

  def generate_rescheduled_imprint(reschedule_group = true)
    if part_of_group? && reschedule_group
      #
      # NOTE this is recursive in that #generate_rescheduled_group! calls #generate_rescheduled_imprint!
      # ---- but with the parameter set to false (stopping an infinite loop from happening).
      #
      new_group = imprint_group.generate_rescheduled_group
      return new_group.imprints.find { |i| i.rescheduled_from_id == id }
    end

    new_imprint = dup
    new_imprint.rescheduled_from_id = rescheduled_from_id || id
    new_imprint.scheduled_at = nil
    new_imprint.completed_at = nil
    new_imprint.completed_by_id = nil

    if self.class.respond_to?(:train_machine)
      new_state = new_imprint.state = self.class.train_machine.first_state
    end

    new_imprint.save!
    # For some reason, the state tends to revert after being saved
    new_imprint.update_column :state, new_state if new_state

    new_imprint
  end

  def mark_original_rescheduled
    if rescheduled_from_id.blank?
      return
    elsif rescheduled_from.blank?
      raise "Imprint ##{id}'s `rescheduled_from` no longer exists"
    end

    rescheduled_from.update_column :state, :rescheduled
    rescheduled_from.create_activity(
      action:     :transition,
      parameters: { event: 'rescheduled' }
    )
  end

  private

  def schedule_conflict?

  end

  def no_circular_reference
    if rescheduled_from_id.present? && rescheduled_from_id == id
      errors.add(:rescheduled_from_id, "cannot be self")
    end
  end

  def reset_state_when_type_changed
    if type_changed?
      self.state = :pending_approval
    end
  end

  def populate_group_fields
    imprint_group.populate_fields_from_imprint(self) if imprint_group_id
  end

  def type_matches_group
    if imprint_group.imprints.where.not(type: type).exists?
      errors.add(
        :imprint_group,
        "##{imprint_group_id} must contain only #{type.underscore.humanize.downcase.pluralize}"
      )
    end
  end

  def synchronize_with_group
    return if imprint_group_id.nil?
    return unless imprint_group_id_changed?

    state = imprint_group.try(:state)
    self.state           = state if state
    self.completed_at    = imprint_group.completed_at
    self.completed_by_id = imprint_group.completed_by_id
  end

  def set_completed_at_if_necessary
    return if completed_at
    return unless respond_to?(:train_machine)
    return if state.to_sym != train_machine.complete_state.to_sym

    self.completed_at = Time.now
  end

  def get_completed_by_id_from_activities
    completion_activity.owner_id rescue nil
  end

  def unschedule
    update_attribute(:scheduled_at, nil) unless part_of_group?
    if part_of_group?
      imprint_group.update_attribute(:scheduled_at, nil)
      imprint_group.imprints.each{|i| i.update_attribute(:scheduled_at, nil)}

      # Weird but intentional - properly reindexes imprint in Sunspot.
      imprint_group.reload.save
      imprint_group.imprints.each{|i| i.reload.save }
    end
  end
end
