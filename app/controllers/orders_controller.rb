class OrdersController < InheritedResources::Base
  respond_to :html, :js

  def index
    q = params[:q]
    @orders = Order.search do
      fulltext q if q
      paginate page: params[:page] || 1
    end
      .results
  end

  private

  def permitted_params
    params.permit(order: [
      :name, :deadline,
      jobs_attributes: [
        :name, :id, :_destroy,
        imprints_attributes: [
          :name, :description, :estimated_time, :scheduled_at,
          :type, :require_manager_signoff, :machine_id, :id, :_destroy, :count
        ]
      ]
    ])
  end
end
