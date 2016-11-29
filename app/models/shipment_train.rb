class ShipmentTrain < ActiveRecord::Base
  include Train
  include PublicActivity::Model
  include TrainSearch
  include Softwear::Auth::BelongsToUser
  include CrmCounterpart
  include Softwear::Library::Enqueue

  self.crm_class = Crm::Shipment
  
  CARRIERS = %w(USPS UPS FedEx Freight)

  tracked only: [:transition]

  belongs_to :shipment_holder, polymorphic: true
  belongs_to_user_called :created_by

  enqueue :update_tracking_in_crm, queue: 'api'

  def self.dependent_field
    :shipment_holder_id
  end

  train_type :post_production
  train initial: :pending_packing, final: :shipped do
    after_transition(on: :shipped) { |t| t.enqueue_update_tracking_in_crm }

    success_event :packed do
      transition :pending_packing => :pending_shipment
    end

    success_event :shipped, 
        params: {
          carrier:    CARRIERS,
          service:    :text_field,
          tracking:   :text_field, 
          shipped_at: :date_field,
          shipped_by_id: -> { [''] + User.all.map(&:for_select) } 
        } do 
      transition :pending_shipment => :shipped
    end
    
    state :pending_packing, type: :success
    state :pending_shipment, type: :success
    state :shipped, type: :success
  end

  def order
    case shipment_holder_type
    when 'Order' then shipment_holder
    when 'Job'   then shipment_holder.try(:order)
    end
  end

  def update_tracking_in_crm
    return if tracking.blank? || !crm? || crm.tracking_number == tracking

    crm.tracking_number = tracking
    crm.save!
  end
end
