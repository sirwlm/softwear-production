class Order < ActiveRecord::Base
  include CrmCounterpart
  include TrainStation

  has_many :jobs,                        dependent: :destroy
  has_many :screen_trains,               dependent: :destroy
  has_many :imprint_groups,              dependent: :destroy
  has_many :digitization_trains,         dependent: :destroy
  has_many :ar3_trains,                  dependent: :destroy
  has_one  :fba_bagging_train,           dependent: :destroy
  has_one  :fba_label_train,             dependent: :destroy
  has_one  :stage_for_fba_bagging_train, dependent: :destroy
  has_one  :shipment_train,              dependent: :destroy, as: :shipment_holder
  has_one  :store_delivery_train,        dependent: :destroy
  has_one  :local_delivery_train,        dependent: :destroy
  has_one  :stage_for_pickup_train,      dependent: :destroy
  has_many :imprints, through: :jobs

  validates :name, :jobs,  presence: true
  validates :softwear_crm_id, uniqueness: true, unless: -> { softwear_crm_id.blank? }

  accepts_nested_attributes_for :jobs, allow_destroy: true

  after_save :add_fba_bagging_train

  searchable do
    text :name, :job_names, :imprint_names, :imprint_descriptions, :customer_name

    boolean(:complete) { complete? }
    boolean(:scheduled) { scheduled? }
    time :created_at
    time :earliest_scheduled_date
    time :latest_scheduled_date
    time :deadline
    string :imprint_state
    string :production_state
  end

  def full_name
    return "FBA - #{name}" if fba?
    return "#{customer_name} - #{name}" unless customer_name.blank?
    return name
  end

  %w(job_names imprint_names imprint_descriptions).each do |name|
    split = name.split('_')

    class_eval <<-RUBY, __FILE__, __LINE__
      def #{name}
        #{split.first.pluralize}.pluck(:#{split.last.singularize}).join(' ')
      end
    RUBY
  end

  def tagged_name(view = nil)
    if fba?
      if view
        return (view.content_tag(:span, "FBA", class: "label label-warning") + " #{name}").html_safe
      else
        return "(FBA) #{full_name}"
      end
    end
    name
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
      # NOTE The labels are generally complete before the order even gets to production
      self.fba_label_train = FbaLabelTrain.new(state: :labels_staged)
    end
    if stage_for_fba_bagging_train.blank?
      self.stage_for_fba_bagging_train = StageForFbaBaggingTrain.new
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

  def self.update_crm_production_status(order_id)
    Order.find(order_id).update_crm_production_status!
  end
  def update_crm_production_status!
    return unless complete?
    return if crm.nil?
    return if crm.production_state == 'complete'
    crm.production_state = 'complete'
    crm.save!
    clear_crm
  end

  def force_complete
    pre_production_trains.each do |t|
      t.force_complete
    end

    production_trains.each do |t|
      unless t.imprint_group.blank?
        if t.imprint_group.scheduled_at.blank?
          next
        end

        if t.imprint_group.completed_at.blank?
          t.imprint_group.update_attribute(:completed_at, t.imprint_group.scheduled_at + t.imprint_group.estimated_time.hours)
        end

        t.update_column(:scheduled_at, t.imprint_group.scheduled_at)
        t.update_column(:completed_at, t.imprint_group.completed_at)
      end
      t.force_complete
    end

    post_production_trains.each do |t|
      t.force_complete
    end

    jobs.each do |j|
      j.pre_production_trains.each do |t|
        t.force_complete
      end

      j.production_trains.each do |t|
        t.force_complete
      end

      j.post_production_trains.each do |t|
        t.force_complete
      end
    end

    begin
      update_crm_production_status!
    rescue StandardError => e
      Rails.logger.error "ERROR TRANSITIONING STATE ON ORDER FORCE COMPLETE: #{e.class}: #{e.message}"
    end
  end

end
