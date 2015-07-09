class TestTrain
  include ActiveModel::Model
  include Train

  attr_accessor :state

  train :state, initial: :first do
    event :normal_success do
      transition :first => :success
    end
    event :normal_failure do
      transition all => :failure
    end

    success_event :won do
      transition :first => :success
    end
    success_event :now_were_here do
      transition :failure => :success
    end
    failure_event :messed_up do
      transition :first => :failure
    end

    event :approve, params: { user_id: [1, 2, 3] } do
      transition :first => :approved
    end
    event :broadcast, public_activity: { message: :string } do
      transition :first => :success
    end
  end
end
