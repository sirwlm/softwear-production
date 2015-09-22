class ImprintGroup < ActiveRecord::Base
  include ColorUtils
  include PublicActivity::Model
  include Schedulable

  tracked only: [:transition]

  belongs_to :order
  has_many :imprints
  belongs_to :machine

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

  def respond_to?(name)
    return super if imprints.empty?
    super || imprints.first.respond_to?(name)
  end
  def method_missing(name, *args, &block)
    return super if imprints.empty?
    imprints.first.send(name, *args, &block)
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
    return 'rgb(204, 204, 204)' if completed?

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
end
