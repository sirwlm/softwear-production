json.array!(@machine.imprints) do |imprint|
  json.partial! 'imprints/for_calendar', imprint: imprint
end
