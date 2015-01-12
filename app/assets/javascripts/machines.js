$(document).ready(function() {

  function getMachineId(){
    if( $('#machine-calendar').length != 0) {
      return $('#machine-calendar').attr('data-machine');
    } else {
      return 0;
    }
  }

  var machineId = getMachineId();

  if(machineId > 0) {
    $.getJSON(machineId +'/scheduled.json', function(machineJobs){
      $('.unscheduled-imprint').each(function() {
        $(this).draggable({
          zIndex: 999,
          revert: false,
          // revertDuration: 0
        });
      });

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

        eventClick: function(event) {
          if (event.url) {
            $.ajax({
              type: 'GET',
              url: '/jobs/1',
              dataType: 'script'
            });

            return false;
          }
        },

        eventDrop: function(eventObject, delta, revert, jsEvent, ui, view) {
          var imprintId = eventObject.id;

          var duration = moment.duration(eventObject.end).subtract(eventObject.start);
          var estimatedTime = duration.hours();

          // TODO this doesn't work 100% yet!

          $.ajax({
            type: 'PUT',
            url: Routes.imprint_path(imprintId),
            dataType: 'json',
            data: { imprint: {
              scheduled_at:   eventObject.start,
              estimated_time: estimatedTime
            } }
          })
          
          .fail(function() {
            alert("Network or server error.");
            revert();
          });
        },

        eventResize: function(eventObject, delta, revert, jsEvent, ui, view) {
          var imprintId = eventObject.id;

          var duration = moment.duration(eventObject.end).subtract(eventObject.start);
          var estimatedTime = duration.hours();

          $.ajax({
            type: 'PUT',
            url: Routes.imprint_path(imprintId),
            dataType: 'json',
            data: { imprint: {
              estimated_time: estimatedTime
            } }
          })
          
          .fail(function() {
            alert("Network or server error.");
            revert();
          });
        },

        drop: function(date) {
          var droppedElement = $(this);
          var imprintId = droppedElement.data('id');

          $(this).remove();

          $.ajax({
            type: 'PUT',
            url: Routes.imprint_path(imprintId),
            dataType: 'json',
            data: { imprint: { scheduled_at: date, machine_id: machineId } }
          })

          .done(function(eventObject) {
            $('#machine-calendar').fullCalendar('renderEvent', eventObject, true);
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


