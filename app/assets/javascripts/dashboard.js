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
  }
});
