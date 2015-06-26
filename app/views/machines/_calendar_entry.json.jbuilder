json.id          event.event_id
json.title       event.display
json.url         url_for(event)
json.start       fullcalendar_format event.scheduled_at
json.end         fullcalendar_format event.estimated_end_at
json.allDay      false
json.borderColor event.border_color unless event.border_color.nil?
json.color       event.calendar_color
json.textColor   event.text_color
json.machine_id  event.machine_id
json.type        event.class.table_name.singularize
