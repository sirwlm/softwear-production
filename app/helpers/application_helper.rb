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
    # 09/18/2014 1:36 PM
    datetime.strftime('%Y-%m-%dT%H:%M:00') unless datetime.blank?
  end
end
