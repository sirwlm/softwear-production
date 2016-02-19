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

  before_save :assign_estimated_end_at
  before_save :reset_state_when_type_changed
  before_save :synchronize_with_group, if: :part_of_group?
  before_save :set_completed_at_if_necessary
  after_commit :populate_group_fields

  belongs_to :job
  belongs_to :imprint_group
  belongs_to :screen_train
  has_many :assigned_screens, through: :screen_train
  has_many :screens, through: :assigned_screens
  has_one :order, through: :job

  searchable do
    text :full_name, :description
    integer :completed_by_id
    string :imprint_group_or_imprint_id_str do
      imprint_group_or_imprint_id_str
    end
    boolean :complete  do
      completed?
    end
    time :scheduled_at
    time :completed_at
    boolean :scheduled do
      !scheduled_at.nil?
    end
    integer :machine_id
  end

  def revolved
    super || false
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
    return "(UNAPPROVED) #{full_name}" unless approved?
    return "(COMPLETE) #{full_name}" if completed?
    full_name
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

  def job_name
    if job.blank?
      'n/a'
    else
      self.job.full_name rescue 'n/a'
    end
  end

  def order_name
    self.order.name rescue 'n/a'
  end

  def name_with_job
    "Job ##{job_id || '?'}: #{name}"
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
        methods: [:train_type, :train_class, :state_type, :details]
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

  private

  def schedule_conflict?

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

  def start_activity
    case type
      when "Print"
        return activities.where("parameters like '%event%at_the_press%'").first
      when "ScreenPrint"
        return activities.where("parameters like '%event%print_started%'").first unless require_manager_signoff?
        return activities.where("parameters like '%event%production_manager_approved%'").first if require_manager_signoff?
      when "DigitalPrint"
        return activities.where("parameters like '%event%start_printing%'").first
      when "EmbroideryPrint"
        return activities.where("parameters like '%event%start_printing%'").first unless require_manager_signoff?
        return activities.where("parameters like '%event%production_manager_approved%'").first if require_manager_signoff?
      when "EquipmentCleaningPrint"
        return activities.where("parameters like '%event%put_equipment_in_dryer%'").first
      when "TransferMakingPrint"
        return activities.where("parameters like '%event%final_test_print_printed%'").first unless require_manager_signoff?
        return activities.where("parameters like '%event%production_manager_approved%'").first if require_manager_signoff?
      when "TransferPrint"
        return activities.where("parameters like '%event%final_test_print_printed%'").first unless require_manager_signoff?
        return activities.where("parameters like '%event%production_manager_approved%'").first if require_manager_signoff?
    end
  end

  def get_started_at_from_activity
    start_activity.created_at rescue nil
  end

  def completion_activity
    case type
      when "Print"
        return activities.where("parameters like '%event%printing_complete%'").first
      when "ScreenPrint"
        return activities.where("parameters like '%event%print_complete%'").first
      when "DigitalPrint"
        return activities.where("parameters like '%event%completed%'").first
      when "EmbroideryPrint"
        return activities.where("parameters like '%event%completed%'").first
      when "EquipmentCleaningPrint"
        return activities.where("parameters like '%event%repacked_bag%'").first
      when "TransferMakingPrint"
        return activities.where("parameters like '%event%completed%'").first
      when "TransferPrint"
        return activities.where("parameters like '%event%completed%'").first
    end
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
