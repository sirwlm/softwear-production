// Routes.metric_activities_for_metric_types

$( document ).ready(function() {
    $('#metric_type_metric_type_class').change(function(e){
        var class_name = $(this).val();
        if($(this).val() == '' || $(this).val() == null) {
            return 0;
        }

        $.ajax
        ({
            url: Routes.metric_activities_for_metric_types_path(class_name, {format: 'json'}),
            type: 'get',
            dataType: 'json'
        }).done(function(activities) {
            var listitems = "<option value=''></option>";
            $.each(activities, function(key, value){
                listitems += '<option value=' + value + '>' + value + '</option>';
            });
            $('#metric_type_start_activity, #metric_type_end_activity, #metric_type_activity').empty();
            $('#metric_type_start_activity, #metric_type_end_activity, #metric_type_activity').append(listitems);
        }).fail(function() {
            console.log('Failed');
        });
    });

    $('#metric_type_measurement_type').change(function(e){
        $('#metric_type_start_activity, #metric_type_end_activity, #metric_type_activity').prop('disabled', true);
        if ($(this).val() == 'count') {
            $('#metric_type_activity').prop('disabled', false);
        } else if ($(this).val() == 'timeframe') {
            $('#metric_type_start_activity, #metric_type_end_activity').prop('disabled', false);
        } else {

        }
    });
});