$(document).ready(function() {

  /*
    $('#calendar').fullCalendar({
        header: {
            left: 'prev,next today',
            center: 'title',
            right: 'month,basicWeek,basicDay'
        },
        defaultView: 'agendaWeek',
        defaultDate: $.datepicker.formatDate('yy-mm-dd', new Date()),
        editable: false,
        eventLimit: true, // allow "more" link when too many events
        events: Routes.imprints_path(),
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
    });
    */

  if ($('#calendar').length != 0) {
    imprintDraggableProperties.stop = function(event, ui) {
      var droppedElement = $(this);

      var eventObject = {
        estimatedHours: 0,
        id: $(this).data('id')
      };

      dropOutside('#calendar', {
        beforeDrop: function() { droppedElement.remove(); },
      })(eventObject, event);
    }

    $('.event-drop').draggable(imprintDraggableProperties);
  }

  imprintCalendarOn('#calendar', {
    events: Routes.imprints_path(),

    removeAfterDrop: function(element) {
      return element.data('machine-id') != null;
    }
  });
});
