module Api
  class TrainsController < Softwear::Lib::ApiController
    protected

    def resource_class
      @resource_class ||= params[:train_class].singularize.camelize.constantize
    end
  end
end
