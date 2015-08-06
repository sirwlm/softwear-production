class Ability
  include CanCan::Ability

  def initialize(user)
    can :manage, :all if user

    cannot [:index, :update, :destroy], Machine unless user.admin

    cannot :manage, User unless user.admin
    can :manage, user    

    cannot :manage, Maintenance unless user.admin
    can :read, Maintenance

    cannot :manage, ApiSetting unless user.admin

  end
end
