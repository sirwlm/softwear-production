class MetricTypesController < InheritedResources::Base
  before_action :populate_metric_type_classes, except: [:index, :destroy]


  def metric_activities_for
    respond_to do |format|
      format.json  do
        render json: MetricType.activity_options_for(params[:class_name])
      end
    end
  end

  private

  def populate_metric_type_classes
    @metric_type_classes = (ActiveRecord::Base.send(:subclasses).
                             select { |d| d.included_modules.include?(PublicActivity::Tracked) }.
                             map(&:name) + Imprint.send(:subclasses).map(&:name)).sort
  end

  def metric_type_params
    params.require(:metric_type).permit(
      :name, :metric_type_class, :measurement_type, :activity,
      :start_activity, :end_activity
    )
  end

end
