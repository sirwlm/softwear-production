class FbaBaggingTrainsController < InheritedResources::Base
  include CalendarEventController

  def show
    super do |format|
      format.js do
        @title = @fba_bagging_train.display
        @object = @fba_bagging_train
        render template: 'trains/show'
      end
    end
  end

  def update
    return super if params[:event]

    update! do |success, failure|
      @title = @fba_bagging_train.display
      @object = @fba_bagging_train

      success.js do
        flash[:notice] = "Updated FBA Bagging Train"

        render template: 'trains/show', locals: { refresh: true }
      end

      failure.js do
        flash[:notice] = "Failed to update FBA Bagging Train: " +
          @fba_bagging_train.errors.full_messages.join(', ')

        render template: 'trains/show', locals: { refresh: true }
      end
    end
  end

  def destroy
    super do |format|
      format.html { redirect_to order_path(@fba_bagging_train.order) }
    end
  end

  protected

  def fba_bagging_train_params
    params.require(:fba_bagging_train).permit(calendar_event_params(:machine_id, :estimated_time))
  end
end
