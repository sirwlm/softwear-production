class ShipmentTrainsController < InheritedResources::Base
  def update
    update! do |success, failure|
      @object = @shipment_train

      success.js do
        flash[:notice] = "Updated Shipment Train"
        render template: 'trains/show'
      end

      success.html do
        flash[:notice] = "Updated Shipment Train"

        redirect_to show_train_path(
          :shipment_train,
          @shipment_train.id
        )
      end

      failure.js do
        flash[:notice] = "Failed to update shipment train " +
          @shipment_train.errors.full_messages.join(', ')
        render template: 'trains/show'
      end
    end
  end
  
  private

  def shipment_train_params
    params.require(:shipment_train).permit(
      [:shipped_by_id, :carrier, :service, :tracking, :time_in_transit]
    )
  end
end
