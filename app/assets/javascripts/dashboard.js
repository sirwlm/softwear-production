$(document).ready(function() {
  if ($('#calendar').length != 0) {
    imprintDraggableProperties.stop = function(event, ui) {
      var droppedElement = $(this);

      var eventObject = {
        estimatedHours: 0,
        id: $(this).data('id')
      };

      dropOutside('#calendar')(eventObject, event);
    }

    $('.event-drop').draggable(imprintDraggableProperties);

    imprintCalendarOn('#calendar', {
      events: Routes.imprints_path(),

      // removeAfterDrop: function(element) {
      //   return element.data('machine-id') != null;
      // }
    });

    var tags = [];
    $('.machine-event-receiver').each(function() {
      tags.push({
        id:   $(this).data('machine-id'),
        text: $(this).data('machine-name')
      });
    });

    $('#show-machines-select').select2({
      tokenSeparators: [','],
      tags: tags,
    });
    $('#show-machines-select').select2('data', $('#show-machines-select').data('initial'));
    $('#show-machines-select').on('change', function(e) {
      if (e.added) {
        $('.event-receiver[data-machine-id="'+e.added.id+'"]').show();
        var start = $('#calendar').fullCalendar('getView').start
        var end   = $('#calendar').fullCalendar('getView').end
        $.ajax({
          url: Routes.imprints_path(),
          dataType: 'json',
          method: 'get',

          data: {
            start: start.format(),
            end: end.format(),
            machine: e.added.id
          },

          success: function(data) {
            data.forEach(function(event) {
              $('#calendar').fullCalendar('renderEvent', event);
            });
          },
          failure: function(data) {
            alert('Server/connection error!');
          }
        });

        $.ajax({
          url: Routes.dashboard_filter_path(),
          dataType: 'json',
          method: 'post',

          data: {
            type: 'show',
            id: e.added.id
          }
        });
      } else if (e.removed) {
        $('.event-receiver[data-machine-id="'+e.removed.id+'"]').hide();
        $('#calendar').fullCalendar(
          'removeEvents', function(event) { return event.machine_id == e.removed.id; }
        );

        $.ajax({
          url: '/dashboard/filter',
          dataType: 'json',
          method: 'post',

          data: {
           type: 'hide',
           id: e.removed.id
          }
        });
      }
      else return;

      // this sucks!
      /*
      var newCalendar = $('<div></div>');
      newCalendar.insertAfter('#calendar');
      $('#calendar').remove();
      newCalendar.prop('id', 'calendar');
      newCalendar.prop('class', 'col-lg-9');
      imprintCalendarOn('#calendar', {
        events: Routes.imprints_path(),
      });
      */
    });
  }
});
