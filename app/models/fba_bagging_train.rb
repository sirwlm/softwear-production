class FbaBaggingTrain < ActiveRecord::Base
  include PublicActivity::Model
  include Train
  include Schedulable
  include ColorUtils

  tracked only: [:transition]

  belongs_to :job

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
  train initial: :ready_to_bag do
    success_event :bagged do
      transition :ready_to_bag => :bagged
    end
  end

  def display
    "#{'(COMPLETE)' if completed?}FBA BAGGING: #{job.name}"
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

  private

  def set_default_machine_id
    return unless machine_id.nil?
    self.machine_id = Machine.where('name LIKE "%Autobagger%"').pluck(:id).first
  end
end
