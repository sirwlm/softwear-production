module Deadlines
  def production_deadline
    @production_deadline ||= begin
      if respond_to?(:deadline)
        in_hand_by = deadline
      elsif job_ok = respond_to?(:job) && !job.nil?
        in_hand_by = job.order.try(:deadline)
      elsif order_ok = respond_to?(:order) && !order.nil?
        in_hand_by = order.deadline
      end
      return if in_hand_by.nil?

      if respond_to?(:shipment_train) && !shipment_train.nil?
        offset = shipment_train.time_in_transit
      elsif job_ok
        offset = job.shipment_train.try(:time_in_transit)
        if offset.nil?
          offset = job.order.try(:shipment_train).try(:time_in_transit)
        end
      elsif order_ok
        offset = order.shipment_train.time_in_transit
      end
      return in_hand_by if offset.nil?

      in_hand_by - offset.days
    end
  end
end
