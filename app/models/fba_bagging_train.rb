class FbaBaggingTrain < ActiveRecord::Base
  include Train

  train_type :post_production
  train initial: :ready_to_bag do
    success_event :bagged do
      transition :ready_to_bag => :bagged
    end
  end
end
