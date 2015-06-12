class OrdersController < InheritedResources::Base
  respond_to :html, :js

  private

  def permitted_params
    params.permit(order: [
      :name, :deadline,
      jobs_attributes: [
        :name,
        imprints_attributes: [
          :name, :description, :estimated_time, :scheduled_at,
          :machine_id, :approved,
        ]
      ]
    ])
  end
end
