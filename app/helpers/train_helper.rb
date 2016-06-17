module TrainHelper
  def difficulty_label(diff)
    if diff <= 3
      "label-info"
    elsif diff <= 6
      "label-warning"
    else
      "label-danger"
    end
  end

  def formatted_scheduled_time(time)
    time.strftime('%a, %b %d, %Y') unless time.nil?
  end

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

  def show_train_path(object, options = {})
    super(object.class.name.underscore, object.id, options)
  end

  def call_ignore_arity(lamb, *args)
    if lamb.arity < args.size
      lamb.call(*args[0...(lamb.arity - args.size)])
    else
      lamb.call(*args)
    end
  end

  def class_of_field(object, field)
    object_class = case object
    when Class  then object
    when String then object.constantize
    else object.class
    end

    object_class.reflect_on_all_associations.each do |assoc|
      if assoc.name.to_sym == field.to_sym || assoc.foreign_key.to_sym == field.to_sym
        return assoc.klass
      end
    end

    nil
  end

  def display_model(model, id)
    record = model.find_by(id: id)
    if record
      record.try(:activity_display) ||
        record.try(:name) ||
        record.try(:email) ||
        "#{model.name} ##{id}"
    else
      "Unknown #{model.name}"
    end
  end

  def options_from_array(arr)
    if arr.last.is_a?(Hash)
      arr.pop
    else
      {}
    end
  end
end
