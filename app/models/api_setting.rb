class ApiSetting < ActiveRecord::Base
  extend FriendlyId
  friendly_id :slug, use: :slugged

  VALID_NAMES = %w(crm)

  validates :endpoint, presence: true, format: { with: URI.regexp }
  validates :homepage, format: { with: URI.regexp }
  validates :auth_token, presence: true
  validates :slug, uniqueness: true, inclusion: { in: VALID_NAMES, message: 'Not a valid site' }

  def self.crm
    find_by(slug: 'crm')
  end
end
