module Api
  class TrainsController < Softwear::Lib::ApiController
    def records
      super || @trains || instance_variable_get("@#{params[:train_class]}")
    end

    def records=(r)
      super || @trains || instance_variable_set("@#{params[:train_class]}", r)
    end

    def record
      super || @train || instance_variable_get("@#{params[:train_class].singularize}")
    end

    def record=(r)
      super || @train || instance_variable_set("@#{params[:train_class].singularize}", r)
    end

    def resource_url(id = nil)
      return if id.nil?
      request.original_url.gsub(/\.json|\/$/, '') + "/#{id}"
    end

    protected

    def resource_class
      @resource_class ||= params[:train_class].singularize.camelize.constantize
    end

    # For create calls
    def permitted_params
      params.permit('train' => permitted_attributes)
    end
  end
end
