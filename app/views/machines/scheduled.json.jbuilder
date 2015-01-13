json.array!(@machine.imprints.scheduled) do |imprint|
  json.partial! 'imprints/for_calendar', imprint: imprint
end
