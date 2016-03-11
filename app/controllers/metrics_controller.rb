class MetricsController < ApplicationController
  def create
    respond_to do |format|
      format.js do
        begin
          @object = params[:object_class].constantize.find(params[:object_id])
          @object.create_metrics
        rescue

        end
      end
    end
  end
end
