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
    begin
      return job.order.complete? if respond_to? :job
      order.complete?
    rescue
      logger.error "No order was available to search for #{self.class.name} #{self.id}"
      nil
    end
  end
  
  def due_at
    begin
      return super if has_attribute?(:due_at)
      order.deadline - 1.day
    rescue
      logger.error "No order was available to search for #{self.class.name} #{self.id}"
      nil
    end
  end

  def order_deadline
    begin
      return job.order.deadline if respond_to? :job
      order.deadline
    rescue
      logger.error "No order was available to search for #{self.class.name} #{self.id}"
      nil
    end
  end

  def order_name
    begin
      return job.order.name if respond_to? :job
      order.name
    rescue
      logger.error "No order was available to search for #{self.class.name} #{self.id}"
      nil
    end
  end

  def fba?
    begin
      return job.order.fba? if respond_to? :job
      order.fba? 
    rescue
      logger.error "No order was available to search for #{self.class.name} #{self.id}"
      nil
    end
  end

end
