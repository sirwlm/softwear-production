class Ability
  include CanCan::Ability

  def initialize(user)
    can :manage, :all if user.admin
    can :read, Report if user.admin
    can :read, Machine if user.admin
    can :read, User if user.admin
    can :read, Maintenance if user.admin
    can :read, ApiSetting if user.admin
  end
end
