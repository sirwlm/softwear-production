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
    }, 'agendaThreeDay');
  }

  setInterval(
    function() {
        window.noSpinner = true;
        if (!mouseDown) reloadCalendar('#machine-calendar');
        window.noSpinner = false;
    },
    30000
  );

});
