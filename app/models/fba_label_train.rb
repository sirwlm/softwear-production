class FbaLabelTrain < ActiveRecord::Base
  include PublicActivity::Model
  include Train

  tracked only: [:transition]

  belongs_to :order

  train_type :pre_production
  train initial: :labels_printed do
    success_event :labels_staged do
      transition :labels_printed => :labels_staged
    end
  end

end
