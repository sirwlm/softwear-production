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
        time :scheduled_at

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
    return job.try(:order).try(:complete?) if respond_to? :job
    order.try(:complete?)
  end

  def due_at
    if has_attribute?(:due_at)
      super
    elsif respond_to?(:production_deadline)
      production_deadline
    else
      (order.try(:deadline) || Time.now) - 1.day
    end
  end

  def order_deadline
    return job.try(:order).try(:deadline) if respond_to? :job
    order.try(:deadline)
  end

  def scheduled_at
    self.scheduled_time
  end

  def order_name
    return job.try(:order).try(:name) if respond_to? :job
    order.try(:name)
  end

  def fba?
    return job.try(:order).try(:fba?) if respond_to? :job
    order.try(:fba?)
  end

end
