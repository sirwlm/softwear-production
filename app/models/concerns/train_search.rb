module TrainSearch
  extend ActiveSupport::Concern
  
  included do 
    if respond_to? :searchable
      searchable do 
        text :human_state_name, :order_name
        string :state

        boolean :complete do 
          self.complete?
        end

        time :due_at
        time :created_at
        
        string :class_name do 
          self.class.name
        end

        time :order_deadline

        boolean :order_complete do 
          self.order_complete?
        end

        boolean :complete do 
          self.complete?
        end
      end
    end
  end

  def order_complete?
    return job.order.complete? if respond_to? :job
    order.complete?
  end
  
  def due_at
    return super if has_attribute?(:due_at)
    (order.try(:deadline) || Time.now) - 1.day
  end

  def order_deadline
    return job.order.deadline if respond_to? :job
    order.deadline
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
