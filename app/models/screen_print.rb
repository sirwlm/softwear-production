class ScreenPrint < Imprint
  include Train

  TRILOC_RESULTS = ['Success', 'Failure', 'Close', 'N/A']

  before_save :transition_to_ready_to_print_if_just_scheduled

  train_type :production
  train initial: :pending_approval, final: :complete do

    after_transition on: :print_complete, do: :mark_completed_at

    success_event :approve do
      transition :pending_approval => :pending_scheduling, if: ->(i) { i.scheduled_at.nil? }
      transition :pending_approval => :pending_setup, unless: ->(i) { i.scheduled_at.nil? }
      transition :pending_scheduling => :pending_setup, if: ->(i) { i.scheduled? }
    end

    success_event :schedule do
      transition :pending_scheduling => :pending_setup
    end

    success_event :start_setup do
      transition :pending_setup => :setting_up
    end

    success_event :setup_complete,
      params: { triloc_result: -> { TRILOC_RESULTS } } do
      transition :setting_up => :pending_print_start, unless: ->(i) { i.require_manager_signoff == true }
      transition :setting_up => :pending_production_manager_approval, if: ->(i) { i.require_manager_signoff == true }
    end

    success_event :production_manager_approved,
        public_activity: { manager: -> { [""] + User.all.map(&:full_name) } } do
      transition :pending_production_manager_approval => :pending_print_start
    end

    success_event :print_started do
      transition :pending_print_start => :printing
    end

    success_event :print_complete do
      transition :printing => :complete
    end

    # delay_event :postponed do
    #
    # end
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
