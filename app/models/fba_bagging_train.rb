class FbaBaggingTrain < ActiveRecord::Base
  include PublicActivity::Model
  include Train
  include Schedulable
  include ColorUtils
  
  tracked only: [:transition]

  belongs_to :order

  validates :order, presence: true

  before_create :set_default_machine_id

  searchable do
    time :scheduled_at
    time :completed_at
    boolean :scheduled do
      !scheduled_at.nil?
    end
    integer :machine_id
  end

  train_type :post_production
  train initial: :ready_to_bag, final: :bagged do
    success_event :bagging_started do 
      transition :ready_to_bag => :bagging_in_progress
    end

    delay_event :delayed, 
      public_activity: {
        reason: :text_field
      } do 
      transition :bagging_in_progress => :delayed
    end

    success_event :bagging_restarted do 
      transition :delayed => :bagging_in_progress
    end

    success_event :bagging_complete do
      transition :bagging_in_progress => :bagged
    end
 
    state :bagging_started, type: :success
    state :delayed, type: :delay
    state :bagged, type: :success

  end

  def display
    "#{'(COMPLETE) ' if completed?}FBA BAGGING: #{order.name}"
  end

  def calendar_color
    return 'white' if machine_id.nil?
    return 'rgb(204, 204, 204)' if completed?

    machine.color
  end

  def text_color
    return machine.color if machine && completed?

    if intensity(calendar_color) > 300
      '#4A4A1F'
    else
      '#FFFF5C'
    end
  end

  def completed_at
    # NOTE this assumes that the only transition is 'Bagged'
    activities.where("`activities`.`key` LIKE '%transition'").pluck(:created_at).first
  end

  def quantity
    order.imprints.pluck(:count).reduce(0, :+)
  end

  def due_date
    order.deadline
  end

  private

  def set_default_machine_id
    return unless machine_id.nil?
    self.machine_id = Machine.where('name LIKE "%Autobagger%"').pluck(:id).first
  end
end
