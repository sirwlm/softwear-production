class Ar3Train < ActiveRecord::Base
  include Train
  include PublicActivity::Model

  tracked only: [:transition]

  belongs_to :order

  searchable do 
    text :human_state_name, :due_at, :artwork_location, :order_name
    string :state
    integer :assigned_to_id, :signed_off_by_id
    time :due_at
    time :created_at
    boolean :complete do 
      self.complete?
    end
  end
  
  train_type :pre_production
  train initial: :pending_ar3_queue, final: :complete do
    success_event :ar3_added, params: { artwork_location: :text_field } do
      transition :pending_ar3_queue => :pending_ar3
    end

    success_event :ar3_made do
      transition :pending_ar3 => :complete
    end
    success_event :ar3_found do
      transition :pending_ar3 => :complete
    end
  end

  def fba?
    order.fba?
  end
  
  def assigned_to_id; return nil; end
  def due_at; return order.deadline - 1.day; end
  # def sign_id; return nil; end

  private

  def order_name
    order.try(:name)
  end

end
