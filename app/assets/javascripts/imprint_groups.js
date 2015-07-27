$(function() {
  var imprintGroups = $('#imprint-groups-panel');
  if (imprintGroups.length === 0) return;


  $('.draggable-imprint').draggable({
    zIndex: 999,
    revert: true,
    revertDuration: 0
  });


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
      console.log("2 big");
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
