class TransferMakingPrint < Imprint
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
    
    event :start_printing do 
      transition :ready_for_production => :printing_in_progress
    end

    event :completed do
      transition :printing_in_progress => :complete
    end
    
  end

  def self.model_name
    Imprint.model_name
  end

  def model_name
    Imprint.model_name
  end
end
