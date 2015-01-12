json.content render partial: 'imprints/unscheduled_entry.html', locals: { imprint: imprint }
json.partial! 'imprints/for_calendar', imprint: imprint
