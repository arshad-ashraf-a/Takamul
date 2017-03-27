$(function () {
    $('iframe').on('load', function () {
        var body = $('iframe').contents().find('body');
        body.css('background-color', '#ffffff');
        body.css('border', '1px #D8D8D8 solid');
        var currentPage = $('iframe').contents().find('body').find('input[id *="CurrentPage"]').css('height', '23px');
        var searchInput = $('iframe').contents().find('body').find('a[title="Find"]').parents('table').first().find('input').css('height', '23px');
        var exportInput = $('iframe').contents().find('body').find('a[title="Export drop down menu"]');
        //var refreshInput = $('iframe').contents().find('body').find('input[title="Refresh"]');
        $('iframe').contents().find('body').find('[id*="_Menu"]').css('background-color', 'rgb(247, 244, 244)');
        //var next = $('iframe').contents().find('body').find('input[id *="Next"][disabled!="disabled"]').parent();
        //var disabledNext = $('iframe').contents().find('body').find('input[id *="Next"][disabled="disabled"]').parent();
        //var last = $('iframe').contents().find('body').find('input[id *="Last"][disabled!="disabled"]').parent();
        //var disabledLast = $('iframe').contents().find('body').find('input[id *="Last"][disabled="disabled"]').parent();
        //var previous = $('iframe').contents().find('body').find('input[id *="Previous"][disabled!="disabled"]').parent();
        //var disabledPrevious = $('iframe').contents().find('body').find('input[id *="Previous"][disabled="disabled"]').parent();
        //var first = $('iframe').contents().find('body').find('input[id *="First"][disabled!="disabled"]').parent();
        //var disabledFirst = $('iframe').contents().find('body').find('input[id *="First"][disabled="disabled"]').parent();
        //next.children().each(function () {
        //    $(this).remove();
        //});
        //disabledNext.children().each(function () {
        //    $(this).remove();
        //});
        //last.children().each(function () {
        //    $(this).remove();
        //});
        //disabledLast.children().each(function () {
        //    $(this).remove();
        //});
        //previous.children().each(function () {
        //    $(this).remove();
        //});
        //disabledPrevious.children().each(function () {
        //    $(this).remove();
        //});
        //first.children().each(function () {
        //    $(this).remove();
        //});
        //disabledFirst.children().each(function () {
        //    $(this).remove();
        //});
        //exportInput.children().each(function () {
        //    $(this).remove();
        //});
        //exportInput.children().last().hide();
        //exportInput.children().first().hide();
        //refreshInput.hide();
        //refreshInput.append()

        //printButton.parents('div').hide();
        //refreshInput.parent().append('<span><i class="report-viewer-paging fa fa-refresh bigger-120"></i></span>');
        //exportInput.append('<span><i class="fa fa-floppy-o bigger-170"></i></span>').find('span').css('padding', '3px');
        //exportInput.append('<span><i class="fa fa-caret-down bigger-120"></i></span>');
        //next.append('<i class="report-viewer-paging ace-icon fa fa-angle-right bigger-140"></i>');
        //last.append('<i class="report-viewer-paging fa fa-angle-double-left bigger-170"></i>');
        //previous.append('<i class="report-viewer-paging fa fa-angle-left bigger-170"></i>');
        //first.append('<i class="report-viewer-paging fa fa-angle-double-right bigger-170"></i>');
        //disabledNext.append('<i class="dis-report-viewer-paging ace-icon fa fa-angle-right bigger-140"></i>');
        //disabledLast.append('<i class="dis-report-viewer-paging fa fa-angle-double-left bigger-170"></i>');
        //disabledPrevious.append('<i class="dis-report-viewer-paging fa fa-angle-left bigger-170"></i>');
        //disabledFirst.append('<i class="dis-report-viewer-paging fa fa-angle-double-right bigger-170"></i>');
    });
});