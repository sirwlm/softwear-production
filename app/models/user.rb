class User < Softwear::Auth::Model
  has_many :user_roles
  has_many :roles, through: :user_roles, source: :role

  # TODO this is real shitty and should be replaced with softwear-hub roles
  def self.managers
    all.select do |user|
      user.roles.any?(&name_is_admin)
    end
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def admin?
    roles.any?(&name_is_admin)
  end

  private

  # 'DRY'
  def name_is_admin
    proc { |r| r.name == "Admin" }
  end

end
