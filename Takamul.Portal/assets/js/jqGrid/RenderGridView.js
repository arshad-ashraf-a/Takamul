////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Public  Variables ,Classes And Selectors 
var editicon = 'ace-icon fa fa-pencil blue';
var addicon = 'ace-icon fa fa-plus-circle purple';
var delicon = 'ace-icon fa fa-trash-o red';
var searchicon = 'ace-icon fa fa-search orange';
var refreshicon = 'ace-icon fa fa-refresh green';
var viewicon = 'ace-icon fa fa-search-plus grey';
var subGridPlusIcon = 'ace-icon fa fa-plus green';
var subGridMinusIcon = 'ace-icon fa fa-minus green';
var subGridOpenIcon = 'ace-icon fa fa-chevron-left green';
var sdatatype = "json";
var oArrRowList = [10, 20, 30, 40, 50];
var nRowNum = 10;
var nDefaultHeight = 450;
var altRows = true;
var multiselect = true;
var multiboxonly = true;
var viewrecords = true;
var GridViewIdDefault = "grid-table";
var GridViewPagerIdDefault = "grid-pager";
var httpverb = "POST";
var contenttype = 'application/json; charset=utf-8';
var AllowEdit = true;
var AllowAdd = true;
var AllowDelete = true;
var AllowSearch = false;
var AllowRefresh = true;
var AllowView = false;
var BindContextMenu = true;
var bEnableSubGrid = false;
var seekfirst = 'fa fa-angle-double-left bigger-140';
var seekprev = 'fa fa-angle-left bigger-140';
var seeknext = 'fa fa-angle-right bigger-140';
var seekend = 'fa fa-angle-double-right bigger-140';
var replacement = { 'ui-icon-seek-first': seekfirst, 'ui-icon-seek-prev': seekprev, 'ui-icon-seek-next': seeknext, 'ui-icon-seek-end': seekend };


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Render Grid View use this if you  need to modify the passed by object on add and edit  and delete 

function RenderGridView(sCaption, oArrColName, sBindUrl, sAddUrl, sEditUrl, sDeleteUrl, oArrColsModel, oArrGridContextMenu, AllowAdd, AllowEdit, AllowDelete, GridViewId, GridViewPagerId, AllowBindContextMenu, EnableSubGrid, EnableAutoResize, nCustomRowNum) {//  Start Render GridView
    if (AllowBindContextMenu === "" || AllowBindContextMenu === null || AllowBindContextMenu === undefined) {
        AllowBindContextMenu = BindContextMenu;
    }
    if (oArrGridContextMenu != "" && oArrGridContextMenu != null && oArrGridContextMenu != undefined) {
        if (AllowBindContextMenu)
            BuildGridViewMenu(oArrColsModel, oArrGridContextMenu);
    }
    if (GridViewId == "" || GridViewId == null || GridViewId == undefined) {
        GridViewId = GridViewIdDefault;
    }
    if (GridViewPagerId == "" || GridViewPagerId == null || GridViewPagerId == undefined) {
        GridViewPagerId = GridViewPagerIdDefault;
    }
    if (EnableSubGrid === "" || EnableSubGrid === null || EnableSubGrid === undefined) {
        EnableSubGrid = bEnableSubGrid;
    }

    if (nCustomRowNum != "" && nCustomRowNum != null && nCustomRowNum != undefined) {
        nRowNum = nCustomRowNum;
    }

    jQuery(function ($) {

        GridResize("#" + GridViewId, EnableAutoResize); //resize to fit page size

        jQuery("#" + GridViewId).jqGrid({
            subGrid: false,
            jsonReader: {
                repeatitems: false,
                root: function (obj) { GridList = obj; return obj; },
                page: function (obj) { return jQuery("#" + GridViewId).jqGrid('getGridParam', 'page'); },
                total: function (obj) { if (obj.length == 0) return 0; else return Math.ceil(obj[0].TotalCount / jQuery("#" + GridViewId).jqGrid('getGridParam', 'rowNum')); },
                records: function (obj) { if (obj.length == 0) return 0; else return obj[0].TotalCount; }
            },
            loadError: function (xhr, status, error) {
                ShowStatusBarNotification('Error has been occured, please try again later', NotificationType.Error);
            },
            mtype: httpverb,
            ajaxGridOptions: { contentType: contenttype },
            serializeGridData: CustomSerializeGridData,
            url: sBindUrl,
            datatype: sdatatype,
            height: nDefaultHeight,
            colNames: oArrColName,
            colModel: oArrColsModel,
            viewrecords: viewrecords,
            rowNum: nRowNum,
            rowList: oArrRowList,
            pager: "#" + GridViewPagerId,
            altRows: altRows,
            multiselect: multiselect,
            subGrid: EnableSubGrid,
            subGridRowExpanded: SubGridRowExpandedEvent,
            multiboxonly: multiboxonly,
            loadComplete: function (data) {
                GridViewLoadComplete(data, GridViewId, GridViewPagerId)
            },
            editurl: sEditUrl,
            caption: sCaption,
            subGridOptions: {
                plusicon: subGridPlusIcon,
                minusicon: subGridMinusIcon,
                openicon: subGridOpenIcon,
                //expandOnLoad: false, 
                //selectOnExpand : false, 
                //reloadOnExpand : true 
            },
        });
        $(window).triggerHandler('resize.jqGrid');//trigger window resize to make the grid get the correct size
        jQuery("#" + GridViewId).jqGrid('navGrid', "#" + GridViewPagerId,
               {
                   edit: AllowEdit,
                   editicon: editicon,
                   add: AllowAdd,
                   addicon: addicon,
                   del: AllowDelete,
                   delicon: delicon,
                   search: AllowSearch,
                   searchicon: searchicon,
                   refresh: AllowRefresh,
                   refreshicon: refreshicon,
                   view: AllowView,
                   viewicon: viewicon,
               },
               {
                   url: sEditUrl, closeAfterEdit: true, beforeShowForm: beforeShowEditForm,
                   afterSubmit: afterSubmitEditForm, onclickSubmit: OnClickSubmitEdit
               },
           {
               url: sAddUrl, closeAfterAdd: true, beforeShowForm: beforeShowAddForm,
               afterSubmit: AfterSubmitAddForm, onclickSubmit: OnClickSubmitAdd
           },
           {
               url: sDeleteUrl, beforeShowForm: beforeShowDeleteForm, afterSubmit: afterSubmitDelete, onclickSubmit: OnClickSubmitDelete
           }
       );
    });
}

/////////////////////////////////////////////////////////////////////////////////////////////////////Common functions for gridview ///////////////////////////////////////////////////////////////////////////////////////////////////////
function GridResize(GridViewId, EnableAutoResize) {
    $(window).on('resize.jqGrid', function () {
        if ($(GridViewId).attr("resizeclass") != undefined && $(GridViewId).attr("resizeclass") != "") {
            if (EnableAutoResize == undefined) {
                $(GridViewId).jqGrid('setGridWidth', $("#" + $(GridViewId).attr("resizeclass")).width());
            }
            else {
                $(GridViewId).jqGrid('setGridWidth', $(GridViewId).attr("widthvalue"));
            }
        }
        else {
            //$(GridViewId).jqGrid('setGridWidth', $(".page-content").width());
            if (EnableAutoResize == undefined) {
                $(GridViewId).jqGrid('setGridWidth', $("#dvMainContentRender").width() + 24);
            }
            else {
                $(GridViewId).jqGrid('setGridWidth', $(GridViewId).attr("widthvalue"));
            }

            $(".ui-jqgrid").addClass("col-xs-12 pull-left");

            //if (LanguageId == "2") {
            //    $(".ui-jqgrid").addClass("col-xs-12 pull-right");
            //}
            //else {
            //    $(".ui-jqgrid").addClass("col-xs-12 pull-left");
            //}

        }
    })
    //resize on sidebar collapse/expand
    var parent_column = $(GridViewId).closest('[class*="col-"]');
    $(document).on('settings.ace.jqGrid', function (ev, event_name, collapsed) {
        if (event_name === 'sidebar_collapsed' || event_name === 'main_container_fixed') {
            setTimeout(function () {
                $(GridViewId).jqGrid('setGridWidth', parent_column.width());
            }, 0);
        }
    });
}
function BuildGridViewMenu(oArrColumnsModel, oArrGridContextMenu) {

    var ColumnOperations = {
        //Added By: Mohammad Alqerm on January 1, 2016
        //Made context menu width fixed.
        name: 'myac', index: '', width: 95, fixed: true, title: false, sortable: false, resize: false, classes: "bootstrap_dropdown",
        formatter: function (cellvalue, options, rowObject) {
            var bHasEdit = false;
            var MenuBuilder = "";
            MenuBuilder += "<div  class='btn-group' id='dvContextMenu_" + options.rowId + "'>";
            MenuBuilder += "<button data-toggle='dropdown' style='padding:2px 6px;' class='btn btn-default btn-white dropdown-toggle' aria-expanded='false'>" + oArrGridContextMenu[0].MenuTitle + "<span class='ace-icon fa fa-caret-down icon-on-right'></span></button>"
            MenuBuilder += "<ul class='dropdown-menu border-lg border-slate-700 no-border-radius active dropdown-menu-" + UlDir + "'>"
            $.each(oArrGridContextMenu, function (MenuIndex, MenuValue) {
                var isVisiable = true;
                if (MenuValue.FlagsArray != undefined && MenuValue.FlagsArray != null && MenuValue.FlagsArray.length > 0) {
                    $.each(MenuValue.FlagsArray, function (FlagsIndex, FlagsValues) {
                        if (rowObject[MenuValue.FlagsArray[FlagsIndex].Key] == MenuValue.FlagsArray[FlagsIndex].Value) {
                            isVisiable = false;
                            return false;
                        }
                    });
                }
                MenuValue.IsVisible = isVisiable;
                //MenuValue.IsVisible
                if (MenuIndex != 0) // Index 0 reserved for menu title
                {
                    if (MenuValue.EventName == "EditRow()") {
                        bHasEdit = true;
                        MenuBuilder += "<li><a href='javascript:void(0)' rowid='" + options.rowId + "'  onclick=\"ShowInlineMenu(this," + options.rowId + ");\">" + MenuValue.Caption + "</a>";
                    }
                    else if (MenuValue.HasRowId) {
                        if (MenuValue.IsVisible) {
                            MenuBuilder += "<li><a href='javascript:void(0)' onclick='" + MenuValue.EventName + "(\"" + options.rowId + "\");" + "'>" + MenuValue.Caption + "</a>";
                        }
                    }
                    else if (MenuValue.MulipleParameters) {

                        var sParameters = '';
                        sParameters += "\"" + options.rowId + "\",";
                        $.each(MenuValue.Parameters, function (Index, value) {
                            sParameters += "\"" + rowObject[value] + "\",";
                        });
                        sParameters = sParameters.trim().substring(0, sParameters.length - 1);
                        if (MenuValue.IsVisible) {
                            MenuBuilder += "<li><a href='javascript:void(0)' RowID='" + options.rowId + "' onclick='" + MenuValue.EventName + "(" + sParameters + ");" + "'>" + MenuValue.Caption + "</a>";
                        }
                    }
                    else if (MenuValue.CustomMulipleParameters) {
                        var sParameters = '';
                        sParameters += "\"" + options.rowId + "\",";
                        $.each(MenuValue.Parameters, function (Index, value) {
                            sParameters += "\"" + value + "\",";
                        });
                        sParameters = sParameters.trim().substring(0, sParameters.length - 1);
                        if (MenuValue.IsVisible) {
                            MenuBuilder += "<li><a href='javascript:void(0)' RowID='" + options.rowId + "' onclick='" + MenuValue.EventName + "(" + sParameters + ");" + "'>" + MenuValue.Caption + "</a>";
                        }
                    }
                    else if (MenuValue.RowId) {
                        if (MenuValue.IsVisible) {
                            var sParameters = "\"" + options.rowId + "\"";
                            MenuBuilder += "<li><a href='javascript:void(0)'   onclick='" + MenuValue.EventName + "(" + sParameters + ");" + "'>" + MenuValue.Caption + "</a>";
                        }
                    }
                    else {
                        if (MenuValue.IsVisible) {
                            MenuBuilder += "<li><a href='javascript:void(0)' onclick='" + MenuValue.EventName + "'>" + MenuValue.Caption + "</a>";
                        }
                    }

                }
                if (!MenuValue.IsVisible && $("#dvContextMenu_" + options.rowId).find("li").length == 0) {
                    MenuBuilder = "";
                }
            });
            MenuBuilder += "</ul>";
            MenuBuilder += "</div>";
            if (bHasEdit) {
                MenuBuilder += RenderInlineOperations(options.rowId);
            }
            return MenuBuilder;
        }, sortable: false, align: 'center', width: 95
    };
    oArrColumnsModel.push(ColumnOperations);
}
function RenderInlineOperations(nRowId) {
    var sRawButtonColumn = "";
    var sRawhtmlButtons = "";
    sRawButtonColumn = "id='jSaveButton_" + nRowId + "' onclick='SaveInline(this," + nRowId + ");'   onmouseover=jQuery(this).addClass('ui-state-hover'); onmouseout=jQuery(this).removeClass('ui-state-hover'); ";
    sRawhtmlButtons += "<div title='Submit' style='float:left;' class='ui-pg-div ui-inline-save' " + sRawButtonColumn + "><span class='ui-icon ui-icon-disk'></span></div>";
    sRawButtonColumn = "id='jCancelButton_" + nRowId + "' onclick='CancelInline(this," + nRowId + ");' onmouseover=jQuery(this).addClass('ui-state-hover'); onmouseout=jQuery(this).removeClass('ui-state-hover'); ";
    sRawhtmlButtons += "<div title='Cancel' style='float:left;margin-left:5px;' class='ui-pg-div ui-inline-cancel' " + sRawButtonColumn + "><span class='ui-icon ui-icon-cancel'></span></div>";
    return "<div   id='dvInlineOperations_" + nRowId + "' style='margin-left:35%;display:none;'>" + sRawhtmlButtons + "</div>";
}
function ShowInlineMenu(Row, nRowId) {
    jQuery.fn.fmatter.rowactions.call(Row, 'edit');
    $("#dvInlineOperations_" + nRowId).show();
    $("#dvInlineOperations_" + nRowId + " >div").show()
    $("#dvContextMenu_" + nRowId).hide();
}
function SaveInline(Row, nRowId) {
    //ShowLoader();
    jQuery.fn.fmatter.rowactions.call(Row, 'save');
    if ($("#" + nRowId).attr("error") != undefined && $("#" + nRowId).attr("error") == "1") {
        $("#dvContextMenu_" + nRowId).hide();
        BeforeShowDialog();
        HideLoader();
    }
}
function CancelInline(Row, nRowId) {
    jQuery.fn.fmatter.rowactions.call(Row, 'cancel');
    $("#dvContextMenu_" + nRowId).fadeIn('slow');
}


function GridViewLoadComplete(table, GridViewIdDefault, GridViewPagerIdDefault) {
    styleCheckbox(table);
    updateActionIcons(table);
    updatePagerIcons(table);
    enableTooltips(table);
    $("#gview_" + GridViewIdDefault).css("direction", GridViewResources.Direction);// Set Table Direction
    $(".ui-jqgrid-titlebar-close").css("left", GridViewResources.FloatingLeft);
    $(".ui-jqgrid-titlebar-close").css("right", GridViewResources.FloatingRight);
    $(".navtable").css("direction", GridViewResources.Direction);
    $("#TblGrid_" + GridViewIdDefault).css("direction", GridViewResources.Direction);
    $(".ui-paging-info").css('text-align', GridViewResources.TextAlign);
    $("#" + GridViewPagerIdDefault + "_center").width("80%");
    $(".ui-pg-table").css("direction", GridViewResources.Direction);
    $("#next_" + GridViewPagerIdDefault + " span").removeClass(GridViewResources.SinglePagerArrowLeft);
    $("#next_" + GridViewPagerIdDefault + " span").addClass(GridViewResources.SinglePagerArrowRight);
    $("#prev_" + GridViewPagerIdDefault + " span").removeClass(GridViewResources.SinglePagerArrowRight);
    $("#prev_" + GridViewPagerIdDefault + " span").addClass(GridViewResources.SinglePagerArrowLeft);
    $("#last_" + GridViewPagerIdDefault + " span").attr("class", "");
    $("#last_" + GridViewPagerIdDefault + " span").addClass("ui-icon ace-icon fa fa-angle-double-right bigger-140");
    $("#first_" + GridViewPagerIdDefault + " span").attr("class", "");
    $("#first_" + GridViewPagerIdDefault + " span").addClass("ui-icon ace-icon fa fa-angle-double-left bigger-140");
    $("#ViewTbl_" + GridViewIdDefault).css("direction", GridViewResources.Direction);
    if (typeof CustomGridViewLoadComplete == "function" && CustomGridViewLoadComplete()) {
        CustomGridViewLoadComplete();
    }
}

function CustomSerializeGridData(postData) {
    var DataSource = [];
    if (typeof CustomSerializeData == "function" && CustomSerializeData(postData)) {
        DataSource = CustomSerializeData(postData);
    }
    else {
        DataSource = JSON.stringify(postData);
    }
    return DataSource;
}

function aceSwitch(cellvalue, options, cell) {
    setTimeout(function () {
        $(cell).find('input[type=checkbox]')
            .addClass('ace ace-switch ace-switch-5')
            .after('<span class="lbl"></span>');
    }, 0);
}
function style_edit_form(form) {
    form.find('input[name=stock]').addClass('ace ace-switch ace-switch-5').after('<span class="lbl"></span>');
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
function beforeShowEditForm(form, TextArea) {
    BeforeShowDialog();
    if (typeof BeforeShowEditDialog == "function" && BeforeShowEditDialog(form)) {
        BeforeShowEditDialog(form);
    }
}

function afterSubmitEditForm(response) {
    if (response.status == 200) {
        if (typeof afterSubmitEditFormCustom == "function" && afterSubmitEditFormCustom()) {
            afterSubmitEditFormCustom();
        }
        RefreshGrid(response.responseText);
    }
}

function beforeShowAddForm(form) {
    BeforeShowDialog();
    if (typeof BeforeShowAddDialog == "function" && BeforeShowAddDialog(form)) {
        BeforeShowAddDialog(form);
    }
}
function AfterSubmitAddForm(response, postdata) {
    if (response.status == 200) {
        RefreshGrid(response.responseText);
    }
}
function beforeShowDeleteForm(e) {
    BeforeShowDialog();
    if (typeof BeforeShowDeleteDialog == "function" && BeforeShowDeleteDialog()) {
        BeforeShowDeleteDialog();
    }
}
function afterSubmitDelete(response) {
    RefreshGrid(response.responseText);
}
function AddNewRow() {
    $('.purple').click();
}
function RefreshGrid(Messages) {
    HideLoader();
    ShowStatusBarNotification(Messages, NotificationType.Success);
    $("#" + GridViewIdDefault).trigger("reloadGrid");
    if ($(".ui-icon-closethick").length > 0) {
        $(".ui-icon-closethick").trigger('click');
    }
    if ($('.ui-jqdialog').length > 0) {
        $('.ui-jqdialog').dialog('destroy').remove();
    }
}
function BeforeShowDialog() {
    $('.fm-button.ui-state-default:hover').css("background-color", "#245F9A !important")
    $('.fm-button:not(.btn)').css("background-color", "#245F9A !important");
    $('.ui-jqdialog-titlebar-close').css("color", "#ffffff !important");
    $("#TblGrid_" + GridViewIdDefault).css("direction", GridViewResources.Direction);
    $(".CaptionTD").append("<span style='color:red;'>*</span>");
    $(".EditButton").css("text-align", "right");
    $("#editmod" + GridViewIdDefault).css({ "width": "37%" });
    $(".EditButton").css("direction", GridViewResources.Direction);
    $(".DataTD").css("text-align", GridViewResources.TextDirection);
    $(".ui-jqdialog").center();
}
function Reload(GridId) {
    if (GridId)
        $("#" + GridId).trigger("reloadGrid");
    else
        $("#" + GridViewIdDefault).trigger("reloadGrid");
}
function ValidateRequiredTextInput(value, colname, message) {
    if (value == "0")
        return [false, message];
    else
        return [true, ""];
};
function OnClickSubmitEdit(options, postData) {
    ShowLoader();
    if (typeof CustomOnClickSubmitEdit == "function" && CustomOnClickSubmitEdit(options, postData)) {
        CustomOnClickSubmitEdit(options, postData);
    }
}
function OnClickSubmitAdd(options, postData) {
    ShowLoader();
    if (typeof CustomOnClickSubmitAdd == "function" && CustomOnClickSubmitAdd(options, postData)) {
        CustomOnClickSubmitAdd(options, postData);
    }
}
function OnClickSubmitDelete(options, postData) {
    ShowLoader();
    if (typeof CustomOnClickSubmitDelete == "function" && CustomOnClickSubmitDelete(options, postData)) {
        CustomOnClickSubmitDelete(options, postData);
    }
}
$(function () {
    $("#" + GridViewIdDefault).bind("jqGridInlineSuccessSaveRow", function (e, Messages, rowid, options) {
        Reload();
        ShowStatusBarNotification(Messages.responseText, NotificationType.Success);
        HideLoader();
    });
});

function DeleteRow() {
    $(".fa-trash-o").click();
}

function OpenEditPopUp() {
    $(".ui-pg-div").find(".fa-pencil").click();
}


function GetColumnsValue(RowID, ColumnName, GridSelector) {
    return $("#" + RowID).find("[aria-describedby='" + GridSelector + "_" + ColumnName + "']").text();
}
function SelectRowBuilder(ColumnName, ColumnCaption, SelectControl, IsMandatory) {
    var sRow = "";
    sRow += "<tr rowpos=\"1\" class=\"FormData\" id=\"tr_" + ColumnName + "\">";
    sRow += "<td class=\"CaptionTD\">" + ColumnCaption + "<span style=\"color:red;\">*</span></td>";
    sRow += "<td class=\"DataTD\" style=\"width: right;\">";
    sRow += SelectControl;
    sRow += "</td></tr>";
    return sRow;
}
function TextBoxRowBuilder(ColumnName, ColumnCaption, Width, IsMandatory, Value) {
    var sRow = "";
    sRow += "<tr rowpos=\"1\" class=\"FormData\" id=\"tr_" + ColumnName + "\">";
    sRow += "<td class=\"CaptionTD\">" + ColumnCaption + "<span style=\"color:red;\">*</span></td>";
    sRow += "<td class=\"DataTD\" style=\"width: right;\">";
    sRow += "<input type='text' name='" + ColumnName + "' = id='" + ColumnName + "'     style='width:" + Width + "px;' value='" + Value + "' />";
    sRow += "</td></tr>";
    return sRow;
}

function SubGridRowExpandedEvent(subgrid_id, row_id) {
    ;
    if (typeof CustomSubGridRowExpanded == "function" && CustomSubGridRowExpanded(subgrid_id, row_id)) {
        CustomSubGridRowExpanded(subgrid_id, row_id);
    }
}




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


