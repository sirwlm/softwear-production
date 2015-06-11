json.id imprint.id
json.title imprint.display
json.url imprint_path(imprint)
json.start fullcalendar_format imprint.scheduled_at
json.end fullcalendar_format imprint.estimated_end_at
json.allDay false
if imprint.completed? || !imprint.approved?
  json.borderColor 'black'
end
json.color imprint.calendar_color
json.textColor imprint.text_color
json.machine_id imprint.machine_id
