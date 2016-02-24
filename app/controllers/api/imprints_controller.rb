module Api
  class ImprintsController < Softwear::Lib::ApiController

    private

    def permitted_attributes
      super + ['at_initial_state']
    end
  end
end
