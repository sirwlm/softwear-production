json.id imprint.id
json.title imprint.display
json.url imprint_path(imprint)
json.start fullcalendar_format imprint.scheduled_at
json.end fullcalendar_format imprint.estimated_end_at
json.allDay false
if imprint.completed?
  json.color 'rgb(204, 204, 204)'
  json.textColor imprint.calendar_color
  json.borderColor 'black'
else
  json.color imprint.calendar_color
end
