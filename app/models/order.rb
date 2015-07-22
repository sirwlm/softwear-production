class Order < ActiveRecord::Base
  # include CrmCounterpart
  has_many :jobs
  has_many :imprints, through: :jobs
  has_one :fba_bagging_train
  has_one :fba_label_train

  validates :name, :jobs,  presence: true

  accepts_nested_attributes_for :jobs, allow_destroy: true

  after_save :add_fba_bagging_train

  searchable do
    text :name, :job_names, :imprint_names, :imprint_descriptions

    boolean(:complete) { complete? }
    boolean(:scheduled) { scheduled? }
    time :earliest_scheduled_date
    time :latest_scheduled_date
  end

  %w(job_names imprint_names imprint_descriptions).each do |name|
    split = name.split('_')

    class_eval <<-RUBY, __FILE__, __LINE__
      def #{name}
        #{split.first.pluralize}.pluck(:#{split.last.singularize}).join(' ')
      end
    RUBY
  end

  def complete?
    imprints.all?(&:completed?)
  end

  def scheduled?
    imprints.all?(&:scheduled?)
  end

  def earliest_scheduled_date
    imprints.pluck(:scheduled_at).compact.min
  end

  def latest_scheduled_date
    imprints.pluck(:scheduled_at).compact.max
  end

  def add_fba_bagging_train
    return unless fba?

    if fba_bagging_train.blank?
      self.fba_bagging_train = FbaBaggingTrain.new
    end
    if fba_label_train.blank?
      self.fba_label_train = FbaLabelTrain.new
    end
  end
end
