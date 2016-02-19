class StoreDeliveryTrain < ActiveRecord::Base
  include PublicActivity::Model
  include Train
  include Softwear::Auth::BelongsToUser

  STORES = ['Ann Arbor', 'Ypsilanti']

  tracked only: [:transition]

  belongs_to :order
  belongs_to_user_called :delivered_by

  train_type :post_production
  train initial: :pending_packing, final: :delivered do
    
    success_event :packed do
      transition :pending_packing => :ready_for_delivery
    end

    success_event :out_for_delivery, 
        params: {
          store_name:    STORES.map {|s| s },
          delivered_by_id: -> { [""] + User.all.map{|u| [u.full_name, u.id] } } 
        } do 
      transition :ready_for_delivery => :out_for_delivery
    end
    
    success_event :delivered do
      transition :out_for_delivery => :delivered
    end

    state :pending_packing, type: :success
    state :ready_to_deliver, type: :success
    state :out_for_delivery, type: :success
    state :delivered, type: :success
  end

end
