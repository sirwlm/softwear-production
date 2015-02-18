module ApplicationHelper

  def alert_class_from_flash_type(flash_type)
    return 'alert-danger' if flash_type == :error || flash_type == :alert
    return 'alert-success' if flash_type == :notice
  end

  def alert_text_from_flash_type(flash_type)
    return 'Error!' if flash_type == :error || flash_type == :alert
    return 'Hooray!' if flash_type == :notice
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
    link_to(record, data: { toggle: 'tooltip' }, class: 'btn btn-xs btn-success', title: 'Show') do
      content_tag :i, '', class: 'glyphicon glyphicon-eye-open'
    end
  end

  def bootstrap_edit_button(record)
    link_to(send("edit_#{record.class.to_s.underscore}_path", record), data: { toggle: 'tooltip' }, class: 'btn btn-xs btn-warning', title: 'Edit') do
      content_tag :i, '', class: 'glyphicon glyphicon-remove-circle'
    end
  end

  def bootstrap_destroy_button(record)
    link_to(record,  method: :delete, data: { confirm: 'Are you sure?', toggle: 'tooltip' }, class: 'btn btn-xs btn-danger', title: 'Destroy') do
      content_tag :i, '', class: 'glyphicon glyphicon-remove-circle'
    end
  end

  def layout_container_type(container_type)
    if container_type == 'fluid'
      'container-fluid'
    else
      'container'
    end
  end
end
