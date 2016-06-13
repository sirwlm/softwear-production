class FbaBaggingTrain < ActiveRecord::Base
  include PublicActivity::Model
  include Train
  include Schedulable
  include ColorUtils
  
  tracked only: [:transition]

  belongs_to :order

  before_create :set_default_machine_id

  searchable do
    time :scheduled_at
    time :completed_at
    boolean :scheduled do
      !scheduled_at.nil?
    end
    integer :machine_id
    boolean :fba
  end

  train_type :post_production
  train initial: :ready_to_bag, final: :bagged do
    after_transition on: :bagging_complete, do: :mark_completed_at

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

  def printed?
    production_trains_complete? ? "Yes" : "No"
  end

  def production_trains_complete?
    train_statuses = order.production_trains.flat_map{ |t| t.state }.uniq
    return (train_statuses.count == 1 && train_statuses.first == "complete")
  end

  def display
    "#{'(COMPLETE) ' if completed?}FBA BAGGING: #{order.name}"
  end

  def inventory_location
    location = order.stage_for_fba_bagging_train.try(:inventory_location)
    return location.nil? ? "Location not set" : location
  end

  def calendar_color
    return 'white' if machine_id.nil?
    return 'rgb(204, 204, 204)' if completed?

    machine.color
  end

  def old_completed_at
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
