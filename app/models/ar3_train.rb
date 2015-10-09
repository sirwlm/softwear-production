class Ar3Train < ActiveRecord::Base
  include Train
  include PublicActivity::Model

  tracked only: [:transition]

  belongs_to :order

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
end
