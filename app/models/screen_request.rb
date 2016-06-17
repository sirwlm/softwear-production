class ScreenRequest < ActiveRecord::Base
  belongs_to :screen_train

  # With this validation, screen requests cannot be created alongside a new screen train.
  # validates :screen_train, presence: true
  validates :frame_type, presence: true, inclusion: { in: Screen::FRAME_TYPES }
  validates :mesh_type, presence: true, inclusion: { in: Screen::MESH_TYPES }
  validates :dimensions, presence: true, inclusion: { in: Screen::DIMENSIONS }
  validates :ink, presence: true
  validates :ink, uniqueness: { scope: :screen_train_id }, if: :screen_train_id

  after_initialize -> (s) { s.frame_type ||= 'Roller'; s.dimensions ||= '23x31' }

  def name
    "#{ink} #{mesh_type} - #{dimensions} - #{screen_train.try(:lpi) || '?'}lpi"
  end

end
