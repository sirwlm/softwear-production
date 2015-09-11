class PreproductionNotesTrainsController < InheritedResources::Base
  def update
    update! do |success, failure|
      @object = @preproduction_notes_train

      success.js do
        flash[:notice] = "Updated preproduction notes"

        render template: 'trains/show'
      end

      success.html do
        flash[:notice] = "Updated preproduction notes"

        redirect_to show_train_path(
          :preproduction_notes_train,
          @preproduction_notes_train.id
        )
      end

      failure.js do
        flash[:notice] = "Failed to update preproduction notes: " +
          @preproduction_notes_train.errors.full_messages.join(', ')

        render template: 'trains/show'
      end
    end
  end

  private

  def preproduction_notes_train_params
    params.require(:preproduction_notes_train).permit(
      [:decoration_placement, :print_order, :special_instructions]
    )
  end
end
