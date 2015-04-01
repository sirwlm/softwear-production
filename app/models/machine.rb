class Machine < ActiveRecord::Base
  has_many :imprints

  validates :imprints, presence: { message: 'all imprints must be scheduled to be assigned a machine',  allow_blank: false }, if: :scheduled?
  validates :name, presence: true, uniqueness: true
  validate :color_is_not_reserved

  def scheduled?
    imprints.map{|x| x.scheduled_at.blank? }.all?
  end

  private

  def color_is_not_reserved
    return if color.nil?

    case color.downcase
    when '#cccccc'
      errors[:color] << 'Cannot match completed imprint color.'
    end
  end

end
