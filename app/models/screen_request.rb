class ScreenRequest < ActiveRecord::Base
  belongs_to :screen_train

  validates :screen_train, presence: true
  validates :frame_type, presence: true, inclusion: { in: Screen::FRAME_TYPES }
  validates :mesh_type, presence: true, inclusion: { in: Screen::MESH_TYPES }
  validates :dimensions, presence: true, inclusion: { in: Screen::DIMENSIONS }
  validates :lpi, presence: true
  validates :ink, presence: true

  before_save :there_can_only_be_one_primary

  def name
    n = "#{ink} #{mesh_type} - #{dimensions} - #{lpi}lpi"
    n = "#{n}*" if primary?
    n 
  end

  private

  def there_can_only_be_one_primary
      self.screen_train.screen_requests.where(ink: self.ink).update_all(primary: false) if self.primary?
  end

end
