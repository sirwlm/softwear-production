class ApiSetting < ActiveRecord::Base
  VALID_NAMES = %w(crm)

  validates :endpoint, presence: true
  validates :auth_token, presence: true
  validates :site_name, uniqueness: true, inclusion: { in: VALID_NAMES, message: 'Not a valid site' }
end