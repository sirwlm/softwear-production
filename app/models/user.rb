class User < Softwear::Auth::Model

  # TODO this is real shitty and should be replaced with softwear-hub roles
  def self.managers
    all.select do |user|
      user.role? 'manager'
    end
  end

  def self.first
    all.first
  end

  def for_select
    [full_name, id]
  end

  def new_record?
    @persisted
  end

end
