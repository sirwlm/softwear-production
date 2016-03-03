class User < Softwear::Auth::Model
  has_many :user_roles
  has_many :roles, through: :user_roles, source: :role

  def self.name_is_admin
    proc { |r| r.name == "Admin" }
  end

  # TODO this is real shitty and should be replaced with softwear-hub roles
  def self.managers
    all.select do |user|
      user.roles.any?(&name_is_admin)
    end
  end

  def self.first
    all.first
  end

  def for_select
    [full_name, id]
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def admin?
    roles.any?(&name_is_admin)
  end

  def new_record?
    @persisted
  end

  def name_is_admin
    self.class.name_is_admin
  end

end
