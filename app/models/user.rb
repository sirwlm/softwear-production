class User < ActiveRecord::Base
  acts_as_paranoid

  has_many :user_roles
  has_many :roles, through: :user_roles

  scope :managers, -> { where(admin: true)  }

  after_initialize :blacklist_admin
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  validates :email, uniqueness: true, email: true

  def full_name
    "#{first_name} #{last_name}"
  end

  def blacklist_admin
    self.admin = false if self.admin.nil?
    true
  end
end
