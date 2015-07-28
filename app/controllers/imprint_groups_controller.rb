class ImprintGroupsController < InheritedResources::Base
  belongs_to :order, optional: true
  before_filter :fetch_imprints, only: [:destroy]

  def create
    super do |format|
      format.js { render }
    end
  end

  def destroy
    super do |format|
      format.js { render }
    end
  end

  private

  def fetch_imprints
    @imprints = Imprint.where(imprint_group_id: params[:id]).to_a
  end
end
