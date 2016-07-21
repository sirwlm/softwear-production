class User < Softwear::Auth::Model
  expire_query_cache_every 10.minutes

  has_many :shown_machines

  def self.separations_manager
    of_role('sep_manager').first
  end

  def self.managers
    all.select do |user|
      user.role? 'manager'
    end
  end

  def self.first
    all.first
  end

  # This is called in train state_machine params options to generate a select box of users
  def self.train_param
    lambda do |_train, view|
      users = all
      first_index = users.index { |u| u.id == view.current_user.id } || 0
      users.unshift users.delete_at(first_index)
      users.map(&:for_select)
    end
  end

  def separations_manager?
    role? 'sep_manager'
  end

  def for_select
    [full_name, id]
  end

  def new_record?
    !@persisted
  end

end
