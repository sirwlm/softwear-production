class EquipmentCleaningPrint < Imprint
  state_machine :state, initial: :pending_approval do 
    event :approve do
      transition :pending_approval => :pending_scheduling, if: ->(i) { i.scheduled_at.nil? }
      transition :pending_approval => :pending_preproduction
    end

    event :schedule do
      transition :pending_scheduling => :ready_to_dry
    end

    event :put_equipment_in_dryer do
      transition :ready_to_dry => :drying
    end
    
    event :put_into_stink_chest do 
      transition :drying => :sanitizing
    end

    event :repacked_bag do
      transition :sanitizing => :complete
    end
    
  end

  def self.model_name
    Imprint.model_name
  end

  def model_name
    Imprint.model_name
  end
end
