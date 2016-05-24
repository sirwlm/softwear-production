module Api
  class TrainsController < Softwear::Lib::ApiController
    include TransitionAction

    def transition
      super

      respond_to do |format|
        format.json do
          if @error
            render json: { error: @error }, status: 406
          elsif @errors
            render json: { error: @errors.map(', ') }, status: 406
          else
            render json: @object.to_json, status: 200
          end
        end
      end
    end

    protected

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

    def resource_class
      @resource_class ||= params[:train_class].singularize.camelize.constantize
    end

    # For create calls
    def permitted_params
      params.permit('train' => permitted_attributes)
    end

    # ------------- Methods used by TransitionAction: ---------------
    def fetch_object
      object_class = params[:train_class].singularize.camelize.constantize
      object_class.find(params[:id])
    end

    def object_param
      :params
    end

    def public_activity_owner
      User.find(params[:owner_id]) if params[:owner_id]
    end
  end
end
