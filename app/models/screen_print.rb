class ScreenPrint < Imprint
  include Train

  TRILOC_RESULTS = ['Success', 'Failure', 'Close', 'N/A']

  before_save :transition_to_ready_to_print_if_just_scheduled

  train_type :production
  train initial: :pending_approval, final: :complete do

    after_transition on: :teardown, do: :mark_completed_at

    success_event :approve do
      transition :pending_approval => :pending_scheduling, if: ->(i) { i.scheduled_at.nil? }
      transition :pending_approval => :pending_preproduction
      transition :pending_scheduling => :ready_to_print, if: ->(i) { i.scheduled? }
    end
    success_event :schedule do
      transition :pending_scheduling => :pending_preproduction
    end

    success_event :preproduction_complete do
      transition :pending_preproduction => :ready_for_production
    end

    success_event :at_the_press do
      transition :ready_for_production => :pending_job_cart
    end

    success_event :cart_staged do
      transition :pending_job_cart => :pending_imprintables
    end

    success_event :imprintables_ready do
      transition :pending_imprintables => :ready_to_print
    end

    success_event :reviewed_production_notes do
      transition :ready_to_print => :pending_press_set_up
    end

    success_event :press_set_up, params: { triloc_result: TRILOC_RESULTS } do
      transition :pending_press_set_up => :pending_registration
    end

    success_event :registered_and_test_printed do
      transition :pending_registration => :pending_tape_off
    end

    success_event :screens_taped_off do
      transition :pending_tape_off => :pending_final_test_print
    end

    success_event :final_test_print_printed do
      transition :pending_final_test_print => :in_production, unless: ->(i) { i.require_manager_signoff == true }
      transition :pending_final_test_print => :pending_production_manager_approval
    end

    success_event :production_manager_approved,
        public_activity: { manager: -> { [""] + User.all.map(&:full_name) } } do
      transition :pending_production_manager_approval => :in_production
    end

    success_event :printing_complete do
      transition :in_production => :numbers_pending_confirmation
    end

    success_event :numbers_confirmed do
      transition :numbers_pending_confirmation => :numbers_confirmed
    end

    success_event :teardown do
      transition :numbers_confirmed => :complete
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
