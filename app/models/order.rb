class Order < ActiveRecord::Base
  include CrmCounterpart
  include TrainStation

  has_many :jobs, dependent: :destroy
  has_many :imprints, through: :jobs
  has_many :imprint_groups, dependent: :destroy
  has_one :fba_bagging_train, dependent: :destroy
  has_one :fba_label_train, dependent: :destroy
  has_one :stage_for_fba_bagging_train, dependent: :destroy
  has_one :shipment_train, dependent: :destroy
  has_one :store_delivery_train, dependent: :destroy
  has_one :local_delivery_train, dependent: :destroy
  has_one :stage_for_pickup_train, dependent: :destroy

  validates :name, :jobs,  presence: true
  validates :softwear_crm_id, uniqueness: true, unless: -> { softwear_crm_id.blank? }

  accepts_nested_attributes_for :jobs, allow_destroy: true

  after_save :add_fba_bagging_train

  searchable do
    text :name, :job_names, :imprint_names, :imprint_descriptions

    boolean(:complete) { complete? }
    boolean(:scheduled) { scheduled? }
    time :created_at
    time :earliest_scheduled_date
    time :latest_scheduled_date
    time :deadline
    string :imprint_state
    string :production_state
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
    imprint_state == 'Printed' && production_state == 'Complete'
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

  def imprint_state
    jobs.all? { |j| j.imprint_state == 'Printed' } ? 'Printed' : 'Pending'
  end

  def production_state
    (order_production_state == 'Complete' && jobs_production_state == 'Complete') ? 'Complete' : 'Pending'
  end

  def order_production_state
    trains.all?(&:complete?) ? 'Complete' : 'Pending'
  end

  def jobs_production_state
    jobs.all? { |j| j.production_state == 'Complete' } ? 'Complete' : 'Pending'
  end
end
