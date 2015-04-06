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
        $.ajax({
          url: '/dashboard/filter',
          dataType: 'json',
          method: 'post',

          data: {
            type: 'show',
            id: e.added.id
          }
        });
      } else if (e.removed) {
        $('.event-receiver[data-machine-id="'+e.removed.id+'"]').hide();
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
    });
  }
});
