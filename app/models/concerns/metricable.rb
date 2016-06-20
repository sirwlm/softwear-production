module Metricable
  extend ActiveSupport::Concern

  included do
    has_many :metrics, as: :metricable
  end

  def create_metrics
    if respond_to?(:imprint_group) && !imprint_group.blank?
      imprint_group.create_imprint_group_metrics
    else
      metrics.destroy_all
      MetricType.where(metric_type_class: self.class.name).each do |metric_type|
        Metric.create_by_metric_type_and_object(metric_type, self)
      end
    end
  end

  def metric_types
    MetricType.where(metric_type_class: self.class.name)
  end

  def create_imprint_group_metrics
    metrics.destroy_all
    MetricType.where(metric_type_class: imprints.first.type).each do |metric_type|
      Metric.create_by_metric_type_and_object(metric_type, self)
    end
  end

  def get_metric_value(metric_name)
    metric = metrics.find_by(name: metric_name)
    metric.value rescue nil
  end

end
