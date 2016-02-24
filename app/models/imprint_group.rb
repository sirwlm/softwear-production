class ImprintGroup < ActiveRecord::Base
  include CrmCounterpart
  include ColorUtils
  include PublicActivity::Model
  include Schedulable

  self.crm_class = Crm::ArtworkRequest

  tracked only: [:transition]

  belongs_to :order
  has_many :imprints
  belongs_to :machine

  after_create :set_order_has_imprint_groups_flag
  before_destroy :remove_imprints

  alias_method :complete?, :completed?

  searchable do
    time :scheduled_at
    time :completed_at
    boolean :scheduled do
      !scheduled_at.nil?
    end
    integer :machine_id
    integer :completed_by_id
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
  end

  def full_name
    "#{order_deadline_day} #{order.name}: Group including #{imprint_names.join(', ')} (#{count})"
  end

  def display
    "#{'(COMPLETE)' if complete?} #{full_name}"
  end

  def event_target
    imprints.first
  end

  def calendar_color
    return 'rgb(58, 135, 173)' if machine.blank?
    return 'rgb(204, 204, 204)' if complete?

    machine.color
  end

  def text_color
    unless machine.blank?
      return machine.color if completed?# || !approved?
    end

    if intensity(calendar_color) > 300
      'black'
    else
      'white'
    end
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
    imprints.pluck(:count).reduce(0, :+)
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

  private

  def start_activity
    case type
      when "Print"
        return activities.where("parameters like '%event%at_the_press%'").first
      when "ScreenPrint"
        return activities.where("parameters like '%event%final_test_print_printed%'").first unless require_manager_signoff?
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
        return activities.where("parameters like '%event%printing_complete%'").first
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

  def set_order_has_imprint_groups_flag
    if order && !order.has_imprint_groups
      order.update_column :has_imprint_groups, true
    end
  end
end
