module TrainHelper
  def train_state_of(object)
    object.class.train_machine.states.match!(object)
  end

  def field_name_for(object, field)
    "#{object.class.model_name.element}[#{field}]"
  end
end
