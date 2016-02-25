class User < ActiveRecord::Base
  acts_as_paranoid
  acts_as_token_authenticatable

  has_many :user_roles
  has_many :roles, through: :user_roles

  default_scope  { order(first_name: :asc) }
  scope :managers, -> { joins(:roles).where(roles: { name: 'Admin' })  }

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  validates :email, uniqueness: true, email: true

  def self.for_select(options = {})
    (options[:include_blank] ? [''] : []) + all.map { |u| [u.full_name, u.id] }
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def admin?
    self.roles.where(name: "Admin").exists?
  end

end
