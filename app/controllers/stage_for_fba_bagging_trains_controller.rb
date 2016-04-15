class StageForFbaBaggingTrainsController < InheritedResources::Base
  include CalendarEventController

  def show
    super do |format|
      format.js do
        @title = @stage_for_fba_bagging_train.display
        @object = @stage_for_fba_bagging_train
        render template: 'trains/show'
      end
    end
  end

  def update
    return super if params[:event]

    update! do |success, failure|
      @title = @stage_for_fba_bagging_train.display
      @object = @stage_for_fba_bagging_train

      success.js do
        flash[:notice] = "Updated Stage For FBA Bagging Train"

        render template: 'trains/show'
      end

      failure.js do
        flash[:notice] = "Failed to update Stage For FBA Bagging Train: " +
          @fba_bagging_train.errors.full_messages.join(', ')

        render template: 'trains/show'
      end
    end
  end

  def destroy
    super do |format|
      format.html { redirect_to order_path(@stage_for_fba_bagging_train.order) }
    end
  end

  protected

  def stage_for_fba_bagging_train_params
    params.require(:stage_for_fba_bagging_train).permit(:inventory_location)
  end
end
