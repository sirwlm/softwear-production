class PreproductionNotesTrain < ActiveRecord::Base
  include Train
  include RequireManagerSignoff
  include PublicActivity::Model

  tracked only: [:transition]

  belongs_to :job
  has_one :order, through: :job

  train_type :pre_production
  train initial: :pending_notes, final: :acknowledged do
    before_transition on: :approve, do: :validate_approval

    success_event :pending_review do
      transition :pending_notes => :pending_review
    end

    success_event :approve, requires_manager_signoff do
      transition :pending_review => :approved
    end

    success_event :acknowledge do
      transition :approved => :acknowledged
    end
  end
end
