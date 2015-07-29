class ImprintGroupsController < InheritedResources::Base
  belongs_to :order, optional: true
  before_filter :fetch_imprints, only: [:destroy]

  def create
    super do |format|
      format.js { render }
    end
  end

  def update
    super do |format|
      format.js { render }
    end
  end

  def destroy
    super do |format|
      format.js { render }
    end
  end

  def edit
    super do |format|
      format.js { render }
    end
  end

  private

  def fetch_imprints
    @imprints = Imprint.where(imprint_group_id: params[:id]).to_a
  end

  def permitted_params
    params.permit(
      imprint_group: [
        :machine_id, :estimated_time, :require_manager_signoff, :order_id
      ]
    )
  end
end
