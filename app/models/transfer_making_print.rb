class TransferMakingPrint < Imprint
  include Train

  before_save :transition_to_ready_to_print_if_just_scheduled

  train_type :production
  train  initial: :pending_approval, final: :complete do

    after_transition on: :completed, do: :mark_completed_at

    success_event :approve do
      transition :pending_approval => :pending_scheduling, if: ->(i) { i.scheduled_at.nil? }
      transition :pending_approval => :pending_preproduction
      transition :pending_scheduling => :ready_to_print, if: ->(i) { i.scheduled? }
    end

    success_event :schedule do
      transition :pending_scheduling => :pending_preproduction
    end

    success_event :preproduction_complete do
      transition :pending_preproduction => :pending_final_test_print
    end

    success_event :final_test_print_printed do
      transition :pending_final_test_print => :ready_for_printing, unless: ->(i) { i.require_manager_signoff == true }
      transition :pending_final_test_print => :pending_production_manager_approval
    end

    success_event :production_manager_approved,
                  public_activity: { manager: -> { [""] + User.all.map { |u| u.full_name } } } do
      transition :pending_production_manager_approval => :ready_for_printing
    end

    success_event :start_printing do
      transition :ready_for_printing => :printing_in_progress
    end

    success_event :completed,
      params: { completed_by_id: User.train_param } do
      transition :printing_in_progress => :complete
    end

    state :pending_approval, type: :success
    state :pending_scheduling, type: :success
    state :pending_preproduction, type: :success
    state :pending_final_test_print, type: :success
    state :pending_production_manager_approval, type: :success
    state :ready_for_printing, type: :success
    state :printing_in_progress, type: :success
    state :complete, type: :success
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
