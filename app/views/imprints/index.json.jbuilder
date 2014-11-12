json.array!(@imprints) do |imprint|
  json.extract! imprint, :id, :estimated_time, :machine_id
  json.title "Imprint #{imprint.id}"
  json.start imprint.scheduled_at
  json.end imprint.estimated_end_at
  json.url imprint_url(imprint, format: :html)
end
