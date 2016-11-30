module Api
  class ImprintGroupsController < Softwear::Lib::ApiController
    private

    def permitted_attributes
      super + ['imprint_ids']
    end

    def permitted_params
      params.permit(
        imprint_group: [
          :softwear_crm_id, :name, :order_id,
          imprint_ids: []
        ]
      )
    end
  end
end
