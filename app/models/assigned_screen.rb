class AssignedScreen < ActiveRecord::Base
  belongs_to :screen
  belongs_to :screen_train
  belongs_to :screen_request
  has_many :imprints, through: :screen_train

  validates :screen, :screen_train, :screen_request, presence: true

end
