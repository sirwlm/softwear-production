class Ability
  include CanCan::Ability

  def initialize(user)
    can :manage, :all if user.admin
    can :read, Report if user.admin
  end
end
