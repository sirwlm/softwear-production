json.array!(@calendar_entries) do |imprint|
  json.partial! 'imprints/for_calendar', imprint: imprint
end

