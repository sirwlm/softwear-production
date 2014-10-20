class ApiSetting < ActiveRecord::Base
  extend FriendlyId
  friendly_id :slug, use: :slugged

  VALID_NAMES = %w(crm)

  validates :endpoint, presence: true
  validates :auth_token, presence: true
  validates :slug, uniqueness: true, inclusion: { in: VALID_NAMES, message: 'Not a valid site' }
end
