class User < ActiveRecord::Base
  acts_as_paranoid

  has_many :user_roles
  has_many :roles, through: :user_roles

  scope :managers, -> { joins(:roles).where(roles: { name: 'Admin' })  }

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  validates :email, uniqueness: true, email: true

  def full_name
    "#{first_name} #{last_name}"
  end

  def admin
    self.roles.where(name: "Admin").exists?
  end

  def admin?
    self.roles.where(name: "Admin").exists?
  end


end
