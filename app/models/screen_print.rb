class ScreenPrint < Imprint

  train_type :production
  train initial: :pending_approval, final: :printing_complete do
    success_event :approve do
      transition :pending_approval => :pending_scheduling, if: ->(i) { i.scheduled_at.nil? }
      transition :pending_approval => :pending_preproduction
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

    success_event :press_set_up do
      transition :pending_press_set_up => :pending_registration
    end

    success_event :registered_and_test_printed do
      transition :pending_registration => :pending_tape_off
    end

    success_event :screens_taped_off do
      transition :pending_tape_off => :pending_final_test_print
    end

    success_event :final_test_print_printed do
      transition :pending_final_test_print => :in_production, if: ->(i) { i.require_manager_signoff == false }
      transition :pending_final_test_print => :pending_production_manager_approval
    end

    success_event :production_manager_approved do
      transition :pending_production_manager_approval => :in_production
    end

    success_event :printing_complete do
      transition :in_production => :numbers_confirmed
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
end
