class OrdersController < InheritedResources::Base
  respond_to :html, :js
  before_filter :assign_fluid_container, only: :show

  def index
    q = params[:q]
    @orders = Order.search do
      if q
        fulltext q[:text] unless q[:text].blank?

        with(:earliest_scheduled_date).greater_than(q[:scheduled_start_at_after]) unless q[:scheduled_start_at_after].blank?
        with(:latest_scheduled_date).less_than(q[:scheduled_start_at_before])     unless q[:scheduled_start_at_before].blank?
        with :complete,  q[:complete]  == 'true' unless q[:complete].blank?
        with :scheduled, q[:scheduled] == 'true' unless q[:scheduled].blank?
      end

      paginate page: params[:page] || 1
    end
      .results
  end

  private

  def permitted_params
    params.permit(order: [
      :name, :softwear_crm_id, :deadline, :fba, :has_imprint_groups,
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
