json.array!(@machine.imprints.scheduled + @machine.maintenances.scheduled) do |event|
  json.partial! 'machines/for_calendar', event: imprint
end
