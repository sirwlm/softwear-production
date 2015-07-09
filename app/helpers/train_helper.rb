module TrainHelper
  def train_state_of(object)
    object.class.train_machine.states.match!(object)
  end
end
