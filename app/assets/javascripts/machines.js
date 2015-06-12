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

      imprintCalendarOn('#machine-calendar', {
        events: machineJobs,
        dropData: { machine_id: machineId }
      });

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


