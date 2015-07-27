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
end
