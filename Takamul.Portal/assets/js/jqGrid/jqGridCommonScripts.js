
    var grid_selector = "#grid-table";
    var pager_selector = "#grid-pager";
    $(window).on('resize.jqGrid', function () {
        $(grid_selector).jqGrid('setGridWidth', $(".page-content").width());
    })
    var parent_column = $(grid_selector).closest('[class*="col-"]');
    $(document).on('settings.ace.jqGrid', function (ev, event_name, collapsed) {
        if (event_name === 'sidebar_collapsed' || event_name === 'main_container_fixed') {
            setTimeout(function () {
                $(grid_selector).jqGrid('setGridWidth', parent_column.width());
            }, 0);
        }
    })

function style_edit_form(form) {
	var buttons = form.next().find('.EditButton .fm-button');
	buttons.addClass('btn btn-sm').find('[class*="-icon"]').hide();
	buttons.eq(0).addClass('btn-primary').prepend('<i class="ace-icon fa fa-check"></i>');
	buttons.eq(1).prepend('<i class="ace-icon fa fa-times"></i>')

	buttons = form.next().find('.navButton a');
	buttons.find('.ui-icon').hide();
	buttons.eq(0).append('<i class="ace-icon fa fa-chevron-left"></i>');
	buttons.eq(1).append('<i class="ace-icon fa fa-chevron-right"></i>');
}

function style_delete_form(form) {
	var buttons = form.next().find('.EditButton .fm-button');
	buttons.addClass('btn btn-sm btn-white btn-round').find('[class*="-icon"]').hide();
	buttons.eq(0).addClass('btn-danger').prepend('<i class="ace-icon fa fa-trash-o"></i>');
	buttons.eq(1).addClass('btn-default').prepend('<i class="ace-icon fa fa-times"></i>')
}

function style_search_filters(form) {
	form.find('.delete-rule').val('X');
	form.find('.add-rule').addClass('btn btn-xs btn-primary');
	form.find('.add-group').addClass('btn btn-xs btn-success');
	form.find('.delete-group').addClass('btn btn-xs btn-danger');
}
function style_search_form(form) {
	var dialog = form.closest('.ui-jqdialog');
	var buttons = dialog.find('.EditTable')
	buttons.find('.EditButton a[id*="_reset"]').addClass('btn btn-sm btn-info').find('.ui-icon').attr('class', 'ace-icon fa fa-retweet');
	buttons.find('.EditButton a[id*="_query"]').addClass('btn btn-sm btn-inverse').find('.ui-icon').attr('class', 'ace-icon fa fa-comment-o');
	buttons.find('.EditButton a[id*="_search"]').addClass('btn btn-sm btn-purple').find('.ui-icon').attr('class', 'ace-icon fa fa-search');
}

function beforeDeleteCallback(e) {
	var form = $(e[0]);
	if (form.data('styled')) return false;
	form.closest('.ui-jqdialog').find('.ui-jqdialog-titlebar').wrapInner('<div class="widget-header" />')
	style_delete_form(form);
	form.data('styled', true);
	$(".ui-jqdialog").center();
}

function beforeEditCallback(e) {
	var form = $(e[0]);
	form.closest('.ui-jqdialog').find('.ui-jqdialog-titlebar').wrapInner('<div class="widget-header" />')
	style_edit_form(form);
}
function styleCheckbox(table) {

}
function updateActionIcons(table) {

}

function updatePagerIcons(table) {
	var replacement =
	{
		'ui-icon-seek-first': 'ace-icon fa fa-angle-double-left bigger-140',
		'ui-icon-seek-prev': 'ace-icon fa fa-angle-left bigger-140',
		'ui-icon-seek-next': 'ace-icon fa fa-angle-right bigger-140',
		'ui-icon-seek-end': 'ace-icon fa fa-angle-double-right bigger-140'
	};
	$('.ui-pg-table:not(.navtable) > tbody > tr > .ui-pg-button > .ui-icon').each(function () {
		var icon = $(this);
		var $class = $.trim(icon.attr('class').replace('ui-icon', ''));

		if ($class in replacement) icon.attr('class', 'ui-icon ' + replacement[$class]);
	})
}

function enableTooltips(table) {
	$('.navtable .ui-pg-button').tooltip({ container: 'body' });
	$(table).find('.ui-pg-div').tooltip({ container: 'body' });
}
function aceSwitch(cellvalue, options, cell) {
    setTimeout(function () {
        $(cell).find('input[type=checkbox]')
            .addClass('ace ace-switch ace-switch-5')
            .after('<span class="lbl"></span>');
    }, 0);
}
