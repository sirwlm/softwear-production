class Print < Imprint
  before_save :transition_to_ready_to_print_if_just_scheduled

  state_machine :state, initial: :pending_approval do
    event :approve do
      transition :pending_approval => :pending_scheduling, if: ->(i) { i.scheduled_at.nil? }
      transition :pending_approval => :ready_to_print
    end

    event :print do
      transition :ready_to_print => :complete
    end
  end

  def self.model_name
    Imprint.model_name
  end

  private

  def transition_to_ready_to_print_if_just_scheduled
    if scheduled_at_was.nil? && !scheduled_at.nil? && state.to_sym == :pending_scheduling
      state = :ready_to_print
    end
  end
end
