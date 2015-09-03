class ButtonMakingPrint < Imprint
  train_type :production 
  train  initial: :pending_approval, final: :complete do 
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
    
    success_event :start_printing do 
      transition :ready_for_production => :printing_in_progress
    end

    success_event :completed do
      transition :printing_in_progress => :complete
    end
    
    state :pending_approval, type: :success
    state :pending_scheduling, type: :success
    state :pending_preproduction, type: :success
    state :ready_for_production, type: :success
    state :printing_in_progress, type: :success
    state :complete, type: :success
  end

  def self.model_name
    Imprint.model_name
  end

  def model_name
    Imprint.model_name
  end
end
