class Metric < ActiveRecord::Base
  belongs_to :metricable, polymorphic: true
  belongs_to :metric_type

  default_scope { order(created_at: :desc) }

  def self.create_by_metric_type_and_object(metric_type, object)
    activities = object.activities.order(created_at: :asc).to_a
    if metric_type.count?
      activities.delete_if{ |a| !a.parameters.has_value?(metric_type.activity) }
      object.metrics << self.create(
            metric_type_id: metric_type.id,
            name: metric_type.name,
            value: activities.count,
            valid_data: true
      )
    end

    if metric_type.timeframe?
      start_activities = object.activities.select{|a| a.parameters.has_value?(metric_type.start_activity)}
      end_activities = object.activities.select{|a| a.parameters.has_value?(metric_type.end_activity)}


      if start_activities.count == end_activities.count
        (0..start_activities.count-1).each do |i|
          object.metrics << self.create(
            metric_type_id: metric_type.id,
            name: metric_type.name,
            value: (end_activities[i].created_at - start_activities[i].created_at),
            valid_data: true
          )
        end
      else
        object.metrics << self.create(
          metric_type_id: metric_type.id,
          name: metric_type.name,
          value: 0,
          valid_data: false,
          invalid_reason: 'There are an inequal amount of start and end activities'
        )
      end
    end
  end
end
