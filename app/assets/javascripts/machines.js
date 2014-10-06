$(document).ready(function() {

    function getMachineId(){
        if( $('#machine-calendar').length != 0) {
            return $('#machine-calendar').attr('data-machine');
        } else {
            return 0;
        }
    }


    $('#machine-calendar').fullCalendar({
        header: {
            left: 'prev,next today',
            center: 'title',
            right: 'month,agendaWeek,agendaDay'
        },
        events: [
            {
                title: 'My Event',
                start: '2014-09-19',
                url: 'http://google.com/'
            }
            // other events here
        ],
        eventClick: function(event) {
            if (event.url) {
                $.ajax({
                    url: '/imprints/1',
                    dataType: 'script'
                });
                $('#contentModal').modal('show');
                return false;
            }
        }
    });
//    $('#machine-calendar').fullCalendar({
//
//        selectable: true,
//        selectHelper: true,
//        select: function(start, end) {
//            var title = prompt('Event Title:');
//            var eventData;
//            if (title) {
//                eventData = {
//                    title: title,
//                    start: start,
//                    end: end,
//                    allDay: false
//                };
//                $('#calendar').fullCalendar('renderEvent', eventData, true); // stick? = true
//            }
//            $('#calendar').fullCalendar('unselect');
//        },
//        editable: true,
//        eventLimit: true, // allow "more" link when too many events
//        events: {
//            url: Routes.machine_scheduled_path( getMachineId(), { format: 'json' })
//        }
//
//    });

});


