class Machine < ActiveRecord::Base
  has_many :imprints

  validates :imprints, presence: { message: 'all imprints must be scheduled to be assigned a machine',  allow_blank: false }, if: :scheduled?
  validates :name, presence: true, uniqueness: true

  def scheduled?
    imprints.map{|x| x.scheduled_at.blank? }.all? && !imprints.map(&:empty?).all?
  end
end
