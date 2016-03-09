class Ability
  include CanCan::Ability

  def initialize(user)
    can :manage, :all if user

    cannot [:index, :update, :destroy], Machine unless user.role?('admin')

    cannot :manage, User unless user.role?('admin')
    can :manage, user

    cannot :manage, Maintenance unless user.role?('admin')
    can :read, Maintenance

    cannot :manage, ApiSetting unless user.role?('admin')

  end
end
