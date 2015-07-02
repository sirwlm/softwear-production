json.content render partial: 'machines/unscheduled_entry.html', locals: { event: event }
json.partial! 'machines/calendar_entry', event: event
