module Api
  class TrainsController < Softwear::Library::ApiController
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

    def create
      self.record = resource_class.create(train_params)

      if record.valid?
        headers['Location'] = resource_url(record.id)
        render_json(status: 201).call
      else
        respond_to { |f| f.json(&render_errors) }
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
      super || instance_variable_set("@#{params[:train_class].singularize}", r)
    end

    def resource_url(id = nil)
      return if id.nil?
      request.original_url.gsub(/\.json|\/$/, '') + "/#{id}"
    end

    def resource_class
      @resource_class ||= params[:train_class].singularize.camelize.constantize
    end

    def permitted_train_attributes
      permitted_attributes.append(
        imprint_ids: [],
        screen_requests_attributes: [
          :frame_type, :mesh_type, :dimensions,
          :ink, :screen_train_id, :id,
          :screen_train_id
        ],
        assigned_screens_attributes: [
          :screen_request_id, :id, :screen_id,
          :double_position
        ]
      )
    end

    # For create calls
    def train_params
      model_name = params[:train_class].singularize
      if params[model_name].present?
        params.require(model_name).permit(permitted_train_attributes)
      else
        params.require('train').permit(permitted_train_attributes)
      end
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
