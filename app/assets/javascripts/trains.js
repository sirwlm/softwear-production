$(function () {
    if ($('#all_dangling_train_ids').length) {
        $('#all_dangling_train_ids').on('change', function () {
            var checked = this.checked;
            $('.dangling-train').each(function () {
                this.checked = checked
            });
        });

        $('.dangling-train').on('change', function () {
            if (!this.checked) {
                $('#all_dangling_train_ids')[0].checked = false;
            }
        });
    }
});
