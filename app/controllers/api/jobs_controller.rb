module Api
  class JobsController < Softwear::Lib::ApiController

    private

    def includes
      [
        :pre_production_trains,
        :production_trains,
        :post_production_trains
      ]
    end

    def permitted_attributes
      super + ['imprintable_train_attributes', 'imprints_attributes']
    end

    def permitted_params
      params.permit(
        job: [
          :softwear_crm_id, :name,

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
