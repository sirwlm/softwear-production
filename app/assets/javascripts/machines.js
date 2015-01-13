$(document).ready(function() {

  function getMachineId() {
    if( $('#machine-calendar').length != 0) {
      return $('#machine-calendar').attr('data-machine');
    } else {
      return 0;
    }
  }

  var machineId = getMachineId();

  if(machineId > 0) {
    $.getJSON(machineId +'/scheduled.json', function(machineJobs) {
      function unscheduledDraggable(element) {
        element.draggable({
          zIndex: 999,
          revert: true,
          revertDuration: 0
        });
      }

      $('.unscheduled-imprint-link').each(function() {
        unscheduledDraggable($(this));
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

      $('#machine-calendar').fullCalendar({
        header: {
          left: 'prev,next today',
          center: 'title',
          right: 'month,agendaWeek,agendaDay'
        },
        defaultView: 'agendaWeek',
        events: machineJobs,
        editable: true,
        droppable: true,
        dragRevertDuration: 0,

        eventClick: function(event) {
          if (event.url) {
            $.ajax({
              type: 'GET',
              url: '/imprints/1',
              dataType: 'script'
            });

            return false;
          }
        },

        eventDragStop: function(eventObject, jsEvent) {
          var unscheduled = $('.unscheduled-imprints');
          if (unscheduled.length <= 0) return;
          var offset = unscheduled.offset();

          var x1 = offset.left;
          var x2 = offset.left + unscheduled.outerWidth(true);
          var y1 = offset.top;
          var y2 = offset.top + unscheduled.outerHeight(true);

          if (jsEvent.pageX >= x1 && jsEvent.pageX <= x2 &&
              jsEvent.pageY >= y1 && jsEvent.pageY <= y2)
          {
            $('#machine-calendar').fullCalendar(
              'removeEvents', eventObject.id
            );

            $.ajax({
              type: 'PUT',
              url: Routes.imprint_path(eventObject.id),
              dataType: 'json',
              data: {
                imprint: {
                  machine_id: null,
                  scheduled_at: null
                }
              }
            })

            .done(function(data) {
              if (!data.content) {
                alert('No!!!!!!1');
                return;
              }
              var estimatedTime = estimatedHoursFor(eventObject);

              var unscheduledEntry = $(data.content);
              $('.unscheduled-imprints').append(unscheduledEntry);
              unscheduledDraggable(unscheduledEntry);
            })

            .fail(function() {
              alert('No!!!!!!');
            });
          }
        },

        eventDrop: onChange,
        eventResize: onChange,

        dropAccept: '.unscheduled-imprint-link',

        drop: function(date) {
          var droppedElement = $(this);
          var imprintId = droppedElement.data('id');

          $(this).remove();

          $.ajax({
            type: 'PUT',
            url: Routes.imprint_path(imprintId),
            dataType: 'json',
            data: {
              imprint: {
                scheduled_at: date.format(),
                machine_id: machineId
              }
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

    });
  }

//  $('#machine-calendar').fullCalendar({
//
//    selectable: true,
//    selectHelper: true,
//    select: function(start, end) {
//      var title = prompt('Event Title:');
//      var eventData;
//      if (title) {
//        eventData = {
//          title: title,
//          start: start,
//          end: end,
//          allDay: false
//        };
//        $('#calendar').fullCalendar('renderEvent', eventData, true); // stick? = true
//      }
//      $('#calendar').fullCalendar('unselect');
//    },
//    editable: true,
//    eventLimit: true, // allow "more" link when too many events
//    events: {
//      url: Routes.machine_scheduled_path( getMachineId(), { format: 'json' })
//    }
//
//  });

});


