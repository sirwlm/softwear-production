class MetricType < ActiveRecord::Base

  MEASUREMENT_TYPES = %w(timeframe count)

  validates :name, :metric_type_class, :measurement_type, presence: true
  validates :activity, presence: true, if: :count?
  validates :start_activity, :end_activity, presence: true, if: :timeframe?

  searchable do
    date :created_at
  end

  def count?
    measurement_type == 'count'
  end

  def timeframe?
    measurement_type == 'timeframe'
  end

  def self.activity_options_for(class_name)
    class_name = 'Imprint' if Imprint.send(:subclasses).map(&:name).include? class_name
    PublicActivity::Activity.where(trackable_type: class_name).
      where("`key` like '%transition' and created_at > ?", Date.today - 30).
      group(:parameters).map{|a| a.parameters['event']}.
      uniq.
      sort!
  end

  def activity_options
    return [] if metric_type_class.blank?
    self.class.activity_options_for(metric_type_class)
  end

end
