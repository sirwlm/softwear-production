$( document ).ready(function() {
    $(document).ajaxStart(function() {
        if (!window.noSpinner) {
            return $('#loading').fadeIn(10);
        }
    });

    $(document).ajaxStop(function() {
        if (!window.noSpinner) {
            return $('#loading').fadeOut(10);
        }
    });

    $(document).on('click', '.hide-loading-spinner', function(event) {
        $('.hide-loading-spinner').on('click', $('#loading').fadeOut("slow"));
        return event.preventDefault();
    });
});