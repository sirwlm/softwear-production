module TrainHelper
  def train_state_of(object)
    object.train_machine.states.match!(object)
  end

  def field_name_for(object, field)
    "#{object.class.model_name.element}[#{field}]"
  end

  def link_to_add_train(object, train_type, container = nil)
    content_tag(:div, class: 'well col-xs-1 add-train-btn') do
      url = new_train_path(object, train_type)
      if container
        url += URI.encode "?container=#{container}"
      end
      link_to '+', url, remote: :true, class: 'btn btn-xl btn-success', data: { container: container }
    end
  end

  def train_entry(object, &block)
    render 'trains/entry', object: object, block: block
  end

  def js_train_entry(object, &block)
    j train_entry(object, &block)
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

  def call_ignore_arity(lamb, *args)
    if lamb.arity < args.size
      lamb.call(*args[0...(lamb.arity - args.size)])
    else
      lamb.cal(*args)
    end
  end
end
