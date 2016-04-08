class Ar3TrainsController < InheritedResources::Base
  def update
    update! do |success, failure|
      @object = @ar3_train
      if @ar3_train.valid?
        @ar3_train.create_activity(
          action: :update,
          owner: current_user
        )
      end

      success.js do
        flash[:notice] = "Updated notes"

        render template: 'trains/show'
      end

      success.html do
        flash[:notice] = "Updated notes"

        redirect_to show_train_path(
          :ar3_train,
          @ar3_train.id
        )
      end

      failure.js do
        flash[:notice] = "Error updating notes: " +
          @ar3_train.errors.full_messages.join(', ')

        render template: 'trains/show'
      end
    end
  end

  def destroy
    @order_id = Ar3Train.where(id: params[:id]).pluck(:order_id).first
    Ar3Train.where(id: params[:id]).destroy_all
    redirect_to order_path(@order_id)
  end

  private

  def ar3_train_params
    params.require(:ar3_train).permit(:notes, :artwork_location, :final_ar3_location)
  end
end
