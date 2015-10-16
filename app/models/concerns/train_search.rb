module TrainSearch
  extend ActiveSupport::Concern

  included do 
    searchable do 
      text :human_state_name, :order_name
      string :state
      time :due_at
      time :created_at
      
      string :class_name do 
        self.class.name
      end
      
      boolean :complete do 
        self.complete?
      end
    end
  end

  
  def due_at
    return send(:due_at) if has_attribute?(:due_at)
    order.deadline - 1.day
  end

  def order_name
    return job.order.name if respond_to? :job
    order.name
  end

  def fba?
    return job.order.fba? if respond_to? :job
    order.fba? 
  end

end
