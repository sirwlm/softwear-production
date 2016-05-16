class ScreenRequest < ActiveRecord::Base
  belongs_to :screen_train

  validates :screen_train, presence: true
  validates :frame_type, presence: true, inclusion: { in: Screen::FRAME_TYPES }
  validates :mesh_type, presence: true, inclusion: { in: Screen::MESH_TYPES }
  validates :dimensions, presence: true, inclusion: { in: Screen::DIMENSIONS }
  validates :ink, presence: true

  def name
    n = "#{ink} #{mesh_type} - #{dimensions} - #{screen_train.try(:lpi) || '?'}lpi"
    n
  end

end
