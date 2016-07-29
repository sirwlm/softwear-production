class ScreenRequest < ActiveRecord::Base
  belongs_to :screen_train
  has_many :imprints, through: :screen_train

  # With this validation, screen requests cannot be created alongside a new screen train.
  # validates :screen_train, presence: true
  validates :frame_type, presence: true, inclusion: { in: Screen::FRAME_TYPES }
  validates :mesh_type, presence: true, inclusion: { in: Screen::MESH_TYPES }
  validates :dimensions, presence: true, inclusion: { in: Screen::DIMENSIONS }
  validates :ink, presence: true
  validates :ink, uniqueness: { scope: :screen_train_id }, if: :screen_train_id

  after_initialize -> (s) { s.frame_type ||= 'Roller'; s.dimensions ||= '23x31' }

  after_create :increment_imprint_screen_count
  after_destroy :decrement_imprint_screen_count

  def name
    "#{ink} #{mesh_type} - #{dimensions} - #{screen_train.try(:lpi) || '?'}lpi"
  end

  def increment_imprint_screen_count
    imprints.each { |i| i.update_column :screen_count, (i.screen_count || 0) + 1 }
  end
  def decrement_imprint_screen_count
    imprints.each { |i| i.update_column :screen_count, (i.screen_count || 0) - 1 }
  end
end
