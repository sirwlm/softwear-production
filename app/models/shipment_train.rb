class ShipmentTrain < ActiveRecord::Base
  include Train
  include PublicActivity::Model

  CARRIERS = %w(USPS UPS FedEx Freight)

  tracked only: [:transition]

  belongs_to :order

  train_type :post_production
  train initial: :pending_packing, final: :shipped do
    
    success_event :packed do
      transition :pending_packing => :pending_shipment
    end

    success_event :shipped, 
        params: {
          carrier:    CARRIERS.map {|c| c },
          service:    :text_field,
          tracking:   :text_field, 
          shipped_at: :date_field,
          shipped_by_id: -> { [""] + User.all.map(&:full_name) } 
        } do 
      transition :pending_shipment => :shipped
    end
    
    state :pending_packing, type: :success
    state :pending_shipment, type: :success
    state :shipped, type: :success
  end

end
