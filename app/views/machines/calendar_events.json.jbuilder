json.array!(@calendar_events) do |event|
  json.partial! 'machines/calendar_entry', event: event
end
