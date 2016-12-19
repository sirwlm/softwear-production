class DigitizationTrainsController < InheritedResources::Base
  def update
    update! do |success, failure|
      @object = @digitization_train
      if @digitization_train.valid?
        @digitization_train.create_activity(
          action: :update,
          owner: current_user
        )
      end

      success.js do
        flash[:notice] = "Updated Digitization Train"

        render template: 'trains/show'
      end

      success.html do
        flash[:notice] = "Updated Digitization Train"

        redirect_to show_train_path(
          :digitization_train,
          @digitization_train.id
        )
      end

      failure.js do
        flash[:notice] = "Error updating notes: " +
          @digitization_train.errors.full_messages.join(', ')

        render template: 'trains/show'
      end
    end
  end

  def destroy
    @order_id = DigitizationTrain.where(id: params[:id]).pluck(:order_id).first
    DigitizationTrain.where(id: params[:id]).destroy_all
    redirect_to order_path(@order_id)
  end

  private

  def digitization_train_params
    params.require(:digitization_train).permit(
      :notes, :stitch_count, :uses_laser, :laser_stitch_count
    )
  end
end
