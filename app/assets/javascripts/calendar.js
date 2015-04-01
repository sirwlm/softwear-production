function imprintCalendarOn(matcher, options) {
  window.calendarMatcher = matcher;

  $(matcher).fullCalendar({
    header: {
      left: 'prev,next today',
      center: 'title',
      right: 'month,agendaWeek,agendaDay'
    },
    defaultView: 'agendaWeek',
    events: options.events,
    editable: true,
    droppable: true,
    dragRevertDuration: 0,

    eventClick: function(jsEvent) {
      if (jsEvent.url) {
        $.ajax({
          type: 'GET',
          url: Routes.imprint_path(jsEvent.id),
          dataType: 'script'
        });

        return false;
      }
    },

    eventDragStop: dropOutside(matcher),
    eventDrop: onChange,
    eventResize: onChange,

    dropAccept: '.event-drop-with-machine',

    drop: function(date) {
      var droppedElement = $(this);
      // if (droppedElement.parent().data('machine-id') == null
      //     &&
      //     $(matcher).data('machine') == null)
      //   return;
      var imprintId = droppedElement.data('id');

      if (options.removeAfterDrop === undefined || options.removeAfterDrop($(this)))
        $(this).remove();

      $.ajax({
        type: 'PUT',
        url: Routes.imprint_path(imprintId),
        dataType: 'json',
        data: {
          imprint: $.extend({ scheduled_at: date.format() }, options.dropData || {})
        }
      })

      .done(function(eventObject) {
        $(matcher).fullCalendar(
          'removeEvents', eventObject.id
        );
        $(matcher).fullCalendar(
          'renderEvent', eventObject, true
        );
      })

      .fail(function() {
        alert("Something went wrong :(");
      });
    }

  });
}

var imprintDraggableProperties = {
  zIndex: 999,
  revert: true,
  revertDuration: 0
}

function imprintDraggable(element) {
  element.draggable(imprintDraggableProperties);
}

$(function() {
  $('.event-drop').each(function() {
    imprintDraggable($(this));
  });
});

function changeEventColor(calendar, eventId, color) {
  var events = $(calendar).fullCalendar('clientEvents', eventId);

  for (var i = 0; i < events.length; i++) {
    var event = events[i];

    if (event.id == eventId) {
      event.color = color;
      $(calendar).fullCalendar('updateEvent', event);
      return true;
    }
    return false;
  }
}

function estimatedHoursFor(eventObject) {
  if (eventObject.estimatedHours)
    return eventObject.estimatedHours;
  else {
    var start = moment(eventObject.start);
    var end = moment(eventObject.end);

    var duration = moment.duration(end).subtract(start);
    return duration.asHours();
  }
}

function onChange(eventObject, delta, revert, jsEvent, ui, view) {
  if (eventObject.allDay) { return; }

  var imprintId = eventObject.id;
  var estimatedTime = estimatedHoursFor(eventObject);

  $.ajax({
    type: 'PUT',
    url: Routes.imprint_path(imprintId),
    dataType: 'json',
    data: {
      imprint: {
        scheduled_at:   eventObject.start.format(),
        estimated_time: estimatedTime
      }
    }
  })

  .done(function(data) {
    var hours = estimatedHoursFor(data);

    $('.event-drop[data-id="'+data.id+'"]')
      .find('.estimated-time')
      .text(hours.toFixed(1));
  })

  .fail(function() {
    alert("Network or server error.");
    revert();
  });
}

function eventIsWithinElement(event, element) {
  var offset = $(element).offset();
  var x1 = offset.left;
  var x2 = offset.left + element.outerWidth(true);
  var y1 = offset.top;
  var y2 = offset.top + element.outerHeight(true);

  return (event.pageX >= x1 && event.pageX <= x2 &&
          event.pageY >= y1 && event.pageY <= y2);
}

function dropOutside(matcher, options) {
  return function(eventObject, jsEvent) {
    $('.event-receiver').each(function() {
      var receiver = $(this);

      if (eventIsWithinElement(jsEvent, receiver)) {
        imprintObject = {
          scheduled_at: null
        };
        if (receiver.data('machine-id'))
          imprintObject.machine_id = receiver.data('machine-id');
        if (receiver.data('no-machine'))
          imprintObject.machine_id = null;

        $(matcher).fullCalendar('removeEvents', eventObject.id);

        $.ajax({
          type: 'PUT',
          url: Routes.imprint_path(eventObject.id),
          dataType: 'json',
          data: {
            imprint: imprintObject,
            return_content: true
          }
        })

        .done(function(data) {
          if (!data.content) {
            alert('Something went wrong! Try refreshing the page.');
            return;
          }
          $('.event-drop[data-id="'+data.id+'"]').remove();
          changeEventColor(matcher, data.id, data.color);

          var estimatedTime = estimatedHoursFor(eventObject);

          var entry = $(data.content);
          receiver.append(entry);
          imprintDraggable(entry);
        })

        .fail(function() {
          alert('Server is either down or messed up.');
        });
      }
    });
  };
}
