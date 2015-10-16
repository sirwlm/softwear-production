class LocalDeliveryTrain < ActiveRecord::Base
  include Train
  include PublicActivity::Model
  include TrainSearch

  tracked only: [:transition]

  belongs_to :delivered_by, class_name: 'User', foreign_key: :delivered_by_id
  belongs_to :order

  train_type :post_production
  train initial: :pending_packing, final: :delivered do
    
    success_event :packed do
      transition :pending_packing => :ready_for_delivery
    end

    success_event :out_for_delivery, 
        params: {
          delivered_by_id: -> { [""] + User.all.map{|x| [x.full_name, x.id] } } 
        } do 
      transition :ready_for_delivery => :out_for_delivery
    end
    
    success_event :delivered, 
      params: {
        delivered_to_name: :text_field
      } do 
      transition :out_for_delivery => :delivered
    end

    state :pending_packing, type: :success
    state :ready_to_deliver, type: :success
    state :out_for_delivery, type: :success
    state :delivered, type: :success
  end

end
