function fullCalendarOn(matcher, events, dropData) {
  $(matcher).fullCalendar({
    header: {
      left: 'prev,next today',
      center: 'title',
      right: 'month,agendaWeek,agendaDay'
    },
    defaultView: 'agendaWeek',
    events: events,
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

    dropAccept: '.event-drop',

    drop: function(date) {
      var droppedElement = $(this);
      var imprintId = droppedElement.data('id');

      $(this).remove();

      $.ajax({
        type: 'PUT',
        url: Routes.imprint_path(imprintId),
        dataType: 'json',
        data: {
          imprint: $.extend({ scheduled_at: date.format() }, dropData)
        }
      })

      .done(function(eventObject) {
        $('#machine-calendar').fullCalendar(
          'renderEvent', eventObject, true
        );
      })

      .fail(function() {
        alert("Something went wrong :(");
      });
    }

  });
}

function imprintDraggable(element) {
  element.draggable({
    zIndex: 999,
    revert: true,
    revertDuration: 0
  });
}

$(function() {
  $('.event-drop').each(function() {
    imprintDraggable($(this));
  });
});

function estimatedHoursFor(eventObject) {
  var duration = moment.duration(eventObject.end)
                       .subtract(eventObject.start);
  return duration.hours();
}

function onChange(eventObject, delta, revert, jsEvent, ui, view) {
  if (eventObject.allDay) { return; }

  var imprintId = eventObject.id;
  var estimatedTime = estimatedHoursFor(eventObject);

  $.ajax({
    type: 'PUT',
    url: Routes.imprint_path(imprintId),
    dataType: 'json',
    data: { imprint: {
      scheduled_at:   eventObject.start.format(),
      estimated_time: estimatedTime
    } }
  })

  .fail(function() {
    alert("Network or server error.");
    revert();
  });
}




function dropOutside(matcher) {
  return function(eventObject, jsEvent) {
    $('.event-receiver').each(function() {
      var receiver = $(this);
      var offset = receiver.offset();

      var x1 = offset.left;
      var x2 = offset.left + receiver.outerWidth(true);
      var y1 = offset.top;
      var y2 = offset.top + receiver.outerHeight(true);

      if (jsEvent.pageX >= x1 && jsEvent.pageX <= x2 &&
          jsEvent.pageY >= y1 && jsEvent.pageY <= y2)
      {
        imprintObject = {};
        if (receiver.data('machine-id')) {
          imprintObject.machine_id = receiver.data('machine-id');
        } else {
          imprintObject.machine_id = null;
          imprintObject.scheduled_at = null;
        }

        $(matcher).fullCalendar(
          'removeEvents', eventObject.id
        );

        $.ajax({
          type: 'PUT',
          url: Routes.imprint_path(eventObject.id),
          dataType: 'json',
          data: { imprint: imprintObject }
        })

        .done(function(data) {
          if (!data.content) {
            alert('Something went wrong! Try refreshing the page.');
            return;
          }
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
