function prepare_failure_buttons(){
    $('#break-link').click(function(e){
        e.preventDefault();
        $('#failed-buttons').hide();
        $('#break-form').show();
    })

    $('#bad-prep-link').click(function(e){
        e.preventDefault();
        $('#failed-buttons').hide();
        $('#bad-prep-form').show();
    })

    $('.cancel-failure').click(function(e){
        $('#failed-buttons').show();
        e.preventDefault();
        $('#bad-prep-form').hide();
        $('#break-form').hide();
    })
}

function prepare_screen_id_input(){
    if( $("#screen-id").size() > 0 ) {
        $('#screen-id').val('');
        $('#screen-id').focus();
    }
}

$(function() {
    $('#contentModal').on('hidden.bs.modal', function () {
        prepare_screen_id_input();
    });

    $('#screen-id').click(function(){
        $(this).val('');
    });

    prepare_failure_buttons();
    prepare_screen_id_input();
});