
json.array!(@machine.imprints) do |imprint|
  json.title 'Imprint Name'
  json.url imprint_path(imprint)
  json.start fullcalendar_format imprint.scheduled_at
  json.end fullcalendar_format imprint.estimated_end_at
#  json.allDay false
end