class ScreenRequest < ActiveRecord::Base
  belongs_to :screen_train

  validates :screen_train, presence: true
  validates :frame_type, presence: true, inclusion: { in: Screen::FRAME_TYPES }
  validates :mesh_type, presence: true, inclusion: { in: Screen::MESH_TYPES }
  validates :dimensions, presence: true, inclusion: { in: Screen::DIMENSIONS }
  validates :ink, presence: true, uniqueness: { scope: :screen_train_id }, if: :screen_train_id

  after_initialize -> (s) { s.frame_type ||= 'Roller'; s.dimensions ||= '21x33' }

  def name
    "#{ink} #{mesh_type} - #{dimensions} - #{screen_train.try(:lpi) || '?'}lpi"
  end

end
