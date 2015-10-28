module Api
  class OrdersController < Softwear::Lib::ApiController

    private

    def includes
      [
        :pre_production_trains,
        :production_trains,
        :post_production_trains,
        jobs: {
          include: [
            :pre_production_trains,
            :production_trains,
            :post_production_trains
          ]
        }
      ]
    end

    def permitted_attributes
      super + ['jobs']
    end

    def permitted_params
      params.permit(
        order: [
          :softwear_crm_id, :deadline, :customer_name,
          :name, :fba, :has_imprint_groups,

          jobs_attributes: [
            :name, :softwear_crm_id,

            imprints_attributes: [
              :softwear_crm_id, :name, :description, :type,
              :count
            ],
            imprintable_train_attributes: [
              :state
            ]
          ]
        ]
      )
    end

    def order_params
      params.require(:order).permit(
        :softwear_crm_id, :deadline, :customer_name, 
        :name, :fba, :has_imprint_groups,

        jobs_attributes: [
          :name, :softwear_crm_id,

          imprints_attributes: [
            :softwear_crm_id, :name, :description, :type,
            :count
          ],
          imprintable_train_attributes: [
            :state
          ]
        ]
      )
    end
  end
end
