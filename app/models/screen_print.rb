class ScreenPrint < Imprint
  state_machine :state, initial: :pending_approval do
    event :approve do
      transition :pending_approval => :pending_scheduling, if: ->(i) { i.scheduled_at.nil? }
      transition :pending_approval => :pending_preproduction
    end

    event :schedule do
      transition :pending_scheduling => :pending_preproduction
    end
    
    event :preproduction_complete do 
      transition :pending_preproduction => :ready_for_production
    end

    event :at_the_press do
     transition :ready_for_production => :pending_job_cart
    end

    event :cart_staged do
      transition :pending_job_cart => :pending_imprintables
    end

    event :imprintables_ready do 
      transition :pending_imprintables => :ready_to_print
    end

    event :reviewed_production_notes do
      transition :ready_to_print => :pending_press_set_up
    end

    event :press_set_up do
      transition :pending_press_set_up => :pending_registration
    end

    event :registered_and_test_printed do
      transition :pending_registration => :pending_tape_off
    end

    event :screens_taped_off do
      transition :pending_tape_off => :pending_final_test_print
    end

    event :final_test_print_printed do
      transition :pending_final_test_print => :in_production, if: ->(i) { i.require_manager_signoff == false }
      transition :pending_final_test_print => :pending_production_manager_approval
    end

    event :production_manager_approved do
      transition :pending_production_manager_approval => :in_production
    end
      
    event :printing_complete do
      transition :in_production => :numbers_confirmed
    end

    event :teardown do
      transition :numbers_confirmed => :complete
    end

  end

  def self.model_name
    Imprint.model_name
  end
end
