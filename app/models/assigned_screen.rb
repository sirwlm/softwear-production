class AssignedScreen < ActiveRecord::Base
  belongs_to :screen
  belongs_to :screen_train
  belongs_to :screen_request
  has_many :imprints, through: :screen_train

  validates :screen, :screen_train, :screen_request, presence: true
  validate :screen_and_requested_screen_match
  validate :there_can_only_be_one_assigned_screen_per_color
  

  private
  
  def screen_and_requested_screen_match
    return if screen.nil? || screen_request.nil?
    errors.add(:screen, 'Assigned screen mesh type must match requested mesh type') unless screen.mesh_type == screen_request.mesh_type
    errors.add(:screen, 'Assigned screen frame_type must match requested frame_type') unless screen.frame_type == screen_request.frame_type
    errors.add(:screen, 'Assigned screen dimensions must match requested dimensions') unless screen.dimensions == screen_request.dimensions
  end

  def there_can_only_be_one_assigned_screen_per_color
  end

end
