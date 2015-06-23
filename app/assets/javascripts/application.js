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

$( document ).ready(function() {
    datetimepickerInit();
    $(document).on('nested:fieldAdded', datetimepickerInit);

    $('.colorpicker').colorpicker()
    $('[data-toggle="tooltip"]').tooltip();
    $('.select2').select2({width: '35%'});
});

