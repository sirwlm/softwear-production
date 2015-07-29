class ImprintGroup < ActiveRecord::Base
  include ColorUtils
  include PublicActivity::Model
  include Schedulable

  tracked only: [:transition]

  belongs_to :order
  has_many :imprints
  belongs_to :machine

  before_destroy :remove_imprints

  def full_name
    "#{order.name}: Group including #{imprint_names.join(', ')}"
  end

  def imprint_names
    imprints.map { |i| "'#{i.job_name} #{i.name}'" }
  end

  def remove_imprints
    imprints.update_all(imprint_group_id: nil)
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
end
