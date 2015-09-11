// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require js-routes
//= require bootstrap-sprockets
//= require moment
//= require fullcalendar
//= require bootstrap-datetimepicker
//= require bootstrap-colorpicker
//= require select2
//= require editable/bootstrap-editable
//= require editable/rails
//= require jquery_nested_form
//= require jquery-tablesorter
//= require twitter/typeahead
//= require bootstrap-wysihtml5
//= require bootstrap-wysihtml5/locales/en-US

//= require_tree .

function datetimepickerInit() {
  $('.datetimepicker-standard').datetimepicker({
    format: 'YYYY-MM-DD HH:mm:ss'
  });
}

function datepickerInit() {
  $('.datepicker-standard').datetimepicker({
    format: 'YYYY-MM-DD'
  });
}

function typeaheadInit() {
  $('.typeahead').each(function() {
    try {
      var data = new Bloodhound({
        local: $(this).data('suggestions') || [],
        queryTokenizer: Bloodhound.tokenizers.whitespace,
        datumTokenizer: Bloodhound.tokenizers.whitespace
      });
      data.initialize();

      $(this).typeahead(null, {
        name: 'suggestions',
        source: data.ttAdapter()
      });

    } catch(e) {
      console.log('WHAT! ' + e);
    }
  });
}

function wysihtmlInit() {
  $('.edit_preproduction_notes_train textarea').each(function() {
    $(this).wysihtml5({
      toolbar: {
        color: true,
        emphasis: {
          small: false
        },
        link: false,
        blockquote: false,
        'font-styles': false
      }
    });
  });
}

$( document ).ready(function() {
  datetimepickerInit();
  datepickerInit();
  typeaheadInit();
  wysihtmlInit();
  $(document).on('nested:fieldAdded', datetimepickerInit);

  $('.colorpicker').colorpicker()
  $('[data-toggle="tooltip"]').tooltip();
  $('.select2').each(function() {
    var width = $(this).data('width');
    if (!width)
      width = '100%';
    $(this).select2({width: width});
  });

  $('.editable').editable();
});

