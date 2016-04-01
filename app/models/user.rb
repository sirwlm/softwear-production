class User < Softwear::Auth::Model

  def self.managers
    all.select do |user|
      user.role? 'manager'
    end
  end

  def self.first
    all.first
  end

  def self.train_param
    lambda do |_train, view|
      users = all
      first_index = users.index { |u| u.id == view.current_user.id } || 0
      users.unshift users.delete_at(first_index)
      users.map(&:for_select)
    end
  end

  def for_select
    [full_name, id]
  end

  def new_record?
    !@persisted
  end

end
