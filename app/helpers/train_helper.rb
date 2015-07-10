module TrainHelper
  def train_state_of(object)
    object.class.train_machine.states.match!(object)
  end

  def field_name_for(object, field)
    "#{object.class.model_name.element}[#{field}]"
  end

  def transition_train_path(object, event)
    super(object.class.model_name.element, object.id, event)
  end
end
