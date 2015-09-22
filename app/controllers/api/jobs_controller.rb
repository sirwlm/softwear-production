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
  end
end
