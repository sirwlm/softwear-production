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

$( document ).ready(function() {
  datetimepickerInit();
  datepickerInit();
  $(document).on('nested:fieldAdded', datetimepickerInit);

  $('.colorpicker').colorpicker()
  $('[data-toggle="tooltip"]').tooltip();
  $('.select2').each(function() {
    var width = $(this).data('width');
    if (!width)
      width = '35%';
    $(this).select2({width: width});
  });

  $('.editable').editable();
});

