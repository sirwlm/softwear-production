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
    imprintCalendarOn('#machine-calendar', {
      events: Routes.calendar_events_machines_path({ machine: machineId }),
      dropData: { machine_id: machineId }
    });
  }

  function refreshMachineEvents(){
    $.ajax({
      url: Routes.machine_path(machineId),
      dataType: 'script'
    });
  }

  if(machineId > 0) {
    setInterval(refreshMachineEvents, 30000 )
  }

});


