function initializeDraggableImprints() {
  $('.draggable-imprint').draggable({
    zIndex: 999,
    revert: true,
    revertDuration: 0,
    stop: function(event, ui) {
      console.log('dropped!');
      var position = {
        top: ui.helper.parent().position().top + ui.position.top,
        left: ui.helper.parent().position().left + ui.position.left
      };

      $('.imprint-group-drop-zone').each(function() {
        if (eventIsWithinElement(event, $(this))) {
          $.ajax({
            url:    Routes.imprint_path(ui.helper.data('imprint-id')),
            method: 'put',
            dataType: 'script',
            data: {
              imprint: {
                imprint_group_id: $(this).data('imprint-group-id')
              },
              render: 'add_to_group'
            },

            failure: function() {
              alert('Network or server error. If the former, try refreshing the page.');
            }
          });

          return;
        }
      });
    }
  });
}

$(document).ready(function() {
  if ( $('#imprint-groups-panel').length === 0) return;
  initializeDraggableImprints();
});
