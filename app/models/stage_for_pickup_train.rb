class StageForPickupTrain < ActiveRecord::Base
  include Train
  include PublicActivity::Model

  tracked only: [:transition]

  belongs_to :order

  train_type :post_production
  train initial: :pending_packing, final: :staged do
    
    success_event :packed do
      transition :pending_packing => :ready_to_stage
    end

    success_event :staged, 
      params: {
        location: :text_field
      } do 
      transition :ready_to_stage => :staged
    end

    state :pending_packing, type: :success
    state :ready_to_stage, type: :success
    state :staged, type: :success
  end

end
