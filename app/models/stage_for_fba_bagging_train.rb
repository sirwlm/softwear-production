class StageForFbaBaggingTrain < ActiveRecord::Base
  include PublicActivity::Model
  include Train

  tracked only: [:transition]

  belongs_to :order

  after_save :update_fba_bagging_train_location

  train_type :post_production
  train initial: :pending_packing, final: :staged do

    success_event :packed do
      transition :pending_packing => :ready_to_stage
    end

    success_event :staged,
      params: {
        inventory_location: :text_field
      } do
      transition :ready_to_stage => :staged
    end

    state :pending_packing, type: :success
    state :ready_to_stage, type: :success
    state :staged, type: :success
  end

  def display
    "Stage for FBA Bagging Train"
  end

  private

  def update_fba_bagging_train_location
    if inventory_location_changed?
      order.fba_bagging_train.update_attribute(:inventory_location, self.inventory_location)
    end
  end

end
