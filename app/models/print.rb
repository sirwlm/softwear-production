class Print < Imprint
  include Train
  
  before_save :transition_to_ready_to_print_if_just_scheduled

  train_type :production
  train  initial: :pending_approval, final: :complete do
  
    after_transition on: :printing_complete, do: :mark_completed_at

    success_event :approve do
      transition :pending_approval => :pending_scheduling, unless: ->(i) { i.scheduled? }
      transition :pending_approval => :ready_to_print
      transition :pending_scheduling => :ready_to_print, if: ->(i) { i.scheduled? }
    end

    success_event :at_the_press do
      transition :ready_to_print => :in_production
    end

    success_event :printing_complete,
      params: { completed_by_id: User.train_param } do
      transition :in_production => :complete
    end
  end

  def self.model_name
    Imprint.model_name
  end

  def model_name
    Imprint.model_name
  end

  private

  def transition_to_ready_to_print_if_just_scheduled
    if scheduled_at_was.nil? && !scheduled_at.nil? && state.to_sym == :pending_scheduling
      self.approve
    end
  end
end
