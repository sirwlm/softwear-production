$(document).ready(function() {

    function getMachineId(){
        if( $('#machine-calendar').length != 0) {
            return $('#machine-calendar').attr('data-machine');
        } else {
            return 0;
        }
    }

    var machineId = getMachineId();
    console.log(machineId);
    if(machineId > 0) {
        $.getJSON(machineId +'/scheduled.json', function(machine_jobs){

            $('#machine-calendar').fullCalendar({
                header: {
                    left: 'prev,next today',
                    center: 'title',
                    right: 'month,agendaWeek,agendaDay'
                },
                defaultView: 'agendaWeek',
                events: machine_jobs,
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
        });
    }

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


