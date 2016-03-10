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
  var imprintGroups = $('#imprint-groups-panel');
  if (imprintGroups.length === 0) return;

  initializeDraggableImprints();

  var jobs = $('#jobs-panel');
  var tooLowToSee = imprintGroups.position().top;
  var imprintGroupsLeft = imprintGroups.position().left;
  var following = false;

  var setSize = function() {
    var options = {};

    imprintGroups.css('max-height', 'inherit');
    if (imprintGroups.height() > $(window).height()) {
      options['overflow'] = 'scroll';
      options['overflow-x'] = 'hidden';
    }
    else {
      options['overflow'] = 'inherit';
    }

    var jobsBottom = jobs.position().top + jobs.height();
    if (imprintGroups.offset().top + imprintGroups.height() >= jobsBottom) {
      options['max-height'] = jobsBottom - $(window).scrollTop();
    }
    else {
      options['max-height'] = $(window).height();
    }

    imprintGroups.css(options);
  };

  $(document).scroll(function() {
    var scrollTop = $(window).scrollTop();

    if (!following && scrollTop > tooLowToSee) {
      imprintGroups.css({
        position: 'fixed',
        top: '0px',
        left: imprintGroupsLeft+'px'
      });
      following = true;
    }
    else if (following ){
      if (scrollTop <= tooLowToSee) {
        imprintGroups.css({ position: 'inherit' });
        following = false;
      }
    }

    setSize();
  });

  $(window).resize(setSize);
  setSize();
});
