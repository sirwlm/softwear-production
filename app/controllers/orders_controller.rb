class OrdersController < InheritedResources::Base
  custom_actions resource: [:dashboard, :imprint_groups]

  respond_to :html, :js
  before_filter :assign_fluid_container, except: [:new, :edit, :dashboard]

  def index
    q = params[:q]
    @orders = Sunspot.search Order do
      if q
        fulltext q[:text] unless q[:text].blank?

        with(:earliest_scheduled_date).greater_than(q[:scheduled_start_at_after]) unless q[:scheduled_start_at_after].blank?
        with(:latest_scheduled_date).less_than(q[:scheduled_start_at_before])     unless q[:scheduled_start_at_before].blank?
        with :complete,  q[:complete]  == 'true' unless q[:complete].blank?
        with :fba,  q[:fba]  == 'true' unless q[:fba].blank?
        with :scheduled, q[:scheduled] == 'true' unless q[:scheduled].blank?

        order_by :deadline, :desc
      else
        with :complete, false
        order_by :deadline, :desc
      end

      paginate page: params[:page] || 1
    end
      .results
  end

  def dashboard
    @order = Order.find(params[:id])
    @jobs = Imprint.search do
      with :imprint_group_id, nil
      with :order_id, params[:id]
      group :job_id do
        limit 5000
      end
      paginate page: 1, per_page: 5000
    end

    @imprint_groups = ImprintGroup.search do
      with :order_id, params[:id]
      paginate page: 1, per_page: 5000
    end.results
  end

  def force_complete
    @order = Order.find(params[:id])
    @order.force_complete
    @order.reload.save
    redirect_to orders_path, flash: {notice: "Successfully force completed order ##{@order.id}, #{@order.name} " }
  end

  private

  def permitted_params
    params.permit(order: [
      :name, :customer_name, :softwear_crm_id, :deadline, :fba, :has_imprint_groups,
      jobs_attributes: [
        :name, :id, :softwear_crm_id, :_destroy,
        imprints_attributes: [
          :name, :description, :estimated_time, :scheduled_at, :softwear_crm_id,
          :type, :require_manager_signoff, :machine_id, :id, :_destroy, :count
        ]
      ]
    ])
  end
end
