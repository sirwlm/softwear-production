json.array!(@machine.imprints.scheduled + @machine.maintenances.scheduled) do |event|
  json.partial! 'machines/calendar_entry', event: imprint
end
