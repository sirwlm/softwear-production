class TestTrain
  include ActiveModel::Model
  include Train

  attr_accessor :state
  attr_accessor :winner_id

  train_type :preproduction

  train :state, initial: :first, final: :success do
    event :normal_success do
      transition :first => :success
    end
    event :normal_failure do
      transition all => :failure
    end

    success_event :won, params: { winner_id: [1, 2, 3] }, public_activity: { user_id: [2, 4, 5] } do
      transition :first => :success
    end
    success_event :now_were_here, public_activity: { message: :text_field } do
      transition :failure => :success
    end
    failure_event :messed_up do
      transition :first => :failure
    end

    event :approve, public_activity: { user_id: [1, 2, 3] } do
      transition :first => :approved
    end
    failure_event :unsucceed, params: { reason: :text_field } do
      transition :success => :first
    end
    event :broadcast, public_activity: { message: :text_field } do
      transition :first => :success
    end
  end

  def update_attributes!(attrs)
    attrs.each { |key, value| send("#{key}=", value) }
    save!
  end
  def update_attributes(attrs)
    attrs.each { |key, value| send("#{key}=", value) }
    save
  end

  def id
    1
  end
end
