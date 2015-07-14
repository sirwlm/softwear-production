module TrainHelper
  def train_state_of(object)
    object.class.train_machine.states.match!(object)
  end

  def field_name_for(object, field)
    "#{object.class.model_name.element}[#{field}]"
  end

  def link_to_add_train(object, train_type)
    content_tag(:div, class: 'well col-xs-1 add-train-btn') do
      link_to '+', new_train_path(object, train_type), remote: :true, class: 'btn btn-xl btn-success'
    end
  end

  def train_entry(object, &block)
    render 'trains/entry', object: object, block: block
  end

  def transition_train_path(object, event)
    super(object.class.name.underscore, object.id, event)
  end
  def new_train_path(object, type)
    super(object.class.name.underscore, object.id, type)
  end
  def show_train_path(object)
    super(object.class.name.underscore, object.id)
  end
end
