class EquipmentCleaningPrint < Imprint
  include Train
  
  train_type :production
  train initial: :pending_approval, final: :complete do 
    success_event :approve do
      transition :pending_approval => :pending_scheduling, if: ->(i) { i.scheduled_at.nil? }
      transition :pending_approval => :pending_preproduction
    end

    success_event :schedule do
      transition :pending_scheduling => :ready_to_dry
    end

    success_event :put_equipment_in_dryer do
      transition :ready_to_dry => :drying
    end
    
    success_event :put_into_stink_chest do 
      transition :drying => :sanitizing
    end

    success_event :repacked_bag do
      transition :sanitizing => :complete
    end
    
    state :pending_approval, type: :success
    state :pending_scheduling, type: :success
    state :ready_to_dry, type: :success
    state :drying, type: :success
    state :sanitizing, type: :success
    state :complete, type: :success
  end

  def self.model_name
    Imprint.model_name
  end

  def model_name
    Imprint.model_name
  end
end
