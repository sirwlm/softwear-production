class PublicActivitiesController < InheritedResources::Base
  defaults resource_class: PublicActivity::Activity, instance_name: 'activity'

  def update
    update! do |success, failure|
      success.json { render @activity }
      failure.json { render @activity }
    end
  end

  private

  def permitted_params
    params.permit(activity: [:id, :created_at])
  end
end
