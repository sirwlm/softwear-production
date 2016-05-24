class Ar3Train < ActiveRecord::Base
  include PublicActivity::Model
  include Train
  include Deadlines

  tracked only: [:transition]

  belongs_to :order

  after_save :die, unless: :order

  searchable do 
    text :artwork_location, :id
    integer :assigned_to_id, :signed_off_by_id
    boolean :fba
  end
  
  train_type :pre_production
  train initial: :pending_ar3_queue, final: :complete do
    success_event :ar3_requested, params: { artwork_location: :text_field } do
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
    order.try(:fba?)
  end
  
  def assigned_to_id; return nil; end
  alias_method :due_at, :production_deadline
  # def sign_id; return nil; end

  private

  def order_name
    order.try(:name)
  end

  def die
    destroy
  end

end
