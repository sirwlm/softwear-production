class OrdersController < InheritedResources::Base
  respond_to :html, :js

  private

  def permitted_params
    params.permit(order: [
      :name, :deadline,
      jobs_attributes: [
        :name, :id, :_destroy,
        imprints_attributes: [
          :name, :description, :estimated_time, :scheduled_at,
          :machine_id, :id, :_destroy, :count
        ]
      ]
    ])
  end
end
