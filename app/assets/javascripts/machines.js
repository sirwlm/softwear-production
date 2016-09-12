$(document).ready(function() {
  var refreshInterval = $("#agenda").data('refresh');

  function getMachineId() {
    if( $('#machine-calendar').length != 0) {
      return $('#machine-calendar').attr('data-machine');
    } else {
      return 0;
    }
  }

  var machineId = getMachineId();

  if(machineId > 0) {
    imprintCalendarOn('#machine-calendar', {
      events: Routes.calendar_events_machines_path({ machine: machineId }),
      dropData: { machine_id: machineId }
    }, 'agendaThreeDay');
  }

  /*setInterval(
    function() {
        window.noSpinner = true;
        if (!mouseDown) reloadCalendar('#machine-calendar');
        window.noSpinner = false;
    },
    refreshInterval
  );
  */
  
  if($("#agenda").length > 0){
    if(location.pathname.includes("machine")){
      var path       = location.pathname.split('/');
      var machine_id = path[2];
      var searchDate = $("#date").val();

      setInterval(function(){
        if (!mouseDown){
          $.ajax({
             url: Routes.machine_agenda_path(machine_id),
             data: { machine: { id: machine_id },  date: searchDate   },
             dataType: "script",
             method: 'get',
          });
        }
      },
      refreshInterval
      );
    }
    else {
      setInterval(function(){
        window.noSpinner = true;
        if(!mouseDown){
          reloadCalendar('#machine-calendar');
        }
        window.noSpinner = false;
      },
      refreshInterval
      );
    }
  }
});
