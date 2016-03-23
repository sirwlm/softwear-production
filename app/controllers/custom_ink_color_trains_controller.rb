class CustomInkColorTrainsController < InheritedResources::Base
  def update
    update! do |success, failure|
      @object = @custom_ink_color_train

      success.js do
        flash[:notice] = "Updated Custom Ink Color Train"

        render template: 'trains/show'
      end

      failure.js do
        flash[:notice] = "Failed to update Custom Ink Color Train: " +
          @custom_ink_color_train.errors.full_messages.join(', ')

        render template: 'trains/show'
      end
    end
  end

  def destroy
    order = Job.joins(:custom_ink_color_trains)
      .where(custom_ink_color_trains: { id: params[:id] })
      .first
      .try(:order)

    destroy! do |format|
      format.html do
        flash[:notice] = "Removed Custom Ink Color Train"
        redirect_to order_path(order) if order
      end
    end
  end

  private

  def custom_ink_color_train_params
    params.require(:custom_ink_color_train).permit([:pantone_color, :volume, :name, :notes])
  end
end
