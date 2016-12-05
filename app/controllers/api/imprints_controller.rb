module Api
  class ImprintsController < Softwear::Library::ApiController

    private

    def permitted_attributes
      super + ['at_initial_state']
    end

    def permitted_params
      params.permit(
        imprint: [
          :softwear_crm_id, :name, :description, :type,
          :count
        ]
      )
    end
  end
end
