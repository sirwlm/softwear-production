module ApplicationHelper

  def alert_class_from_flash_type(flash_type)
    return 'alert-danger' if flash_type == 'error' || flash_type == 'alert'
    return 'alert-success' if flash_type == 'notice' || flash_type == 'success'
  end

  def alert_text_from_flash_type(flash_type)
    return 'Error!' if flash_type == 'error' || flash_type == 'alert'
    return 'Hooray!' if flash_type == 'notice'
  end

  def datetimepicker_format(datetime)
    # 09/18/2014 1:36 PM
    datetime.strftime('%m/%d/%Y %I:%M %p') unless datetime.blank?
  end

  def fullcalendar_format(datetime)
    # 09-18-2014 1:36
    datetime.strftime('%Y-%m-%d %T') unless datetime.blank?
  end

  def model_table_row_id(object)
    "#{object.class.name.underscore}_#{object.id}"
  end

  def human_boolean(bool)
    bool ? 'Yes' : 'No'
  end

  def create_or_edit_text(object)
    object.new_record? ? 'Create' : 'Update'
  end

  def bootstrap_show_button(record)
    link_to(record, data: { toggle: 'tooltip' }, class: 'btn btn-sm btn-success', title: 'Show') do
      content_tag :i, '', class: 'glyphicon glyphicon-eye-open'
    end
  end

  def bootstrap_edit_button(record)
    link_to(send("edit_#{record.class.model_name.to_s.underscore}_path", record), data: { toggle: 'tooltip' }, class: 'btn btn-sm btn-warning', title: 'Edit') do
      content_tag :i, '', class: 'glyphicon glyphicon-edit'
    end
  end

  def bootstrap_destroy_button(record)
    link_to(record,  method: :delete, data: { confirm: 'Are you sure?', toggle: 'tooltip' }, class: 'btn btn-sm btn-danger', title: 'Destroy') do
      content_tag :i, '', class: 'glyphicon glyphicon-remove-circle'
    end
  end

  def bootstrap_show_train_button(train, new = true)
    link_to(show_train_path(train, new: new), data: { toggle: 'tooltip' }, class: 'btn btn-sm btn-success', title: 'Show', remote: :true) do
      content_tag :i, '', class: 'fa fa-eye'
    end
  end

  def bootstrap_edit_train_button(record)
    link_to('#', data: { toggle: 'tooltip' }, class: 'btn btn-sm btn-warning', title: 'Edit') do
      content_tag :i, '', class: 'fa fa-pencil'
    end
  end

  def layout_container_type(container_type)
    if container_type == 'fluid'
      'container-fluid'
    else
      'container'
    end
  end

  def date_field_tag(*args)
    unless args.last.is_a?(Hash)
      args << {}
    end
    if args.last[:class].is_a?(String)
      args.last[:class] += ' datetimepicker-standard'
    else
      args.last[:class] ||= 'datetimepicker-standard'
    end
    text_field_tag(*args)
  end

  def calendar_url_for(event)
    if event.kind_of? Train or event.is_a? ImprintGroup
      show_train_path(event)
    else
      url_for(event)
    end
  end

  def format_metric(metric)
    if metric.metric_type.timeframe?
      seconds_to_hours_minutes(metric.value)
    elsif metric.metric_type.count?
      pluralize(metric.value, 'times')
    end
  end

  def seconds_to_hours_minutes(seconds)
    begin
      Time.at(seconds).utc.strftime("%khr %Mmin")
    rescue Exception => e
      "N/A"
    end
  end


  def seconds_to_minutes(seconds)
    begin
      seconds / 60
    rescue Exception => e
      "N/A"
    end
  end

  def current_view
    session[:current_view]
  end

  def table_display_date(date)
    datetime.strftime("%F") rescue 'Not Set'
  end

  def table_display_datetime(datetime)
    datetime.strftime("%F %l:%M%P") rescue 'Not Set'
  end

  def train_table_row_class(train)
    return 'success' if train.try :complete?
    return 'warning' if train.train_state_type(train.state.to_sym) == :delay
    return 'danger' if train.train_state_type(train.state.to_sym) == :failure
    return 'info'
  end

  def pretty_train_state(tag, train)
    content_tag tag, class: train_state_alert_class(train) do
      content_tag :strong do
        train.human_state_name
      end
    end
  end

  def train_state_alert_class(train)
    return 'alert alert-success text-center' if train.try :complete?
    return 'alert alert-warning text-center' if train.train_state_type(train.state.to_sym) == :delay
    return 'alert alert-danger text-center' if train.train_state_type(train.state.to_sym) == :failure
    return 'alert alert-info text-center'
  end

  def format_scheduled_at(object)
    object.scheduled_at.strftime('%Y-%m-%d %I:%M%P') rescue "Not Scheduled"
  end

  def format_datetime_am_pm(datetime)
    datetime.strftime('%Y-%m-%d %I:%M%P') rescue "Date not set"
  end

  def display_name_for_train_event_category(category)
    return 'Failure or Needs Reschedule' if category.to_s == 'failure'
    return  category.to_s.humanize
  end

  def imprint_or_imprint_group(production_train)
    return ImprintGroup if production_train.class == ImprintGroup
    return Imprint
  end
end
