///////////////////////////////////////////////////////////////////////// Ajax Calls \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
function AjaxCallAndFillDropDown(Url, HttpVerb, Async, DropDown, Key, Value, SelectMessage, Parameters, Showloading) {
    var Options = "<option value='-99'>" + SelectMessage + "</option>";
    var oParameters = [];
    if (null != Parameters && undefined != Parameters) {
        oParameters = Parameters;
    }
    if (Showloading) {
        ShowLoader();
    }
    $.ajax({
        url: Url,
        data: oParameters,
        type: HttpVerb,
        async: Async,
        beforeSend: function () { },
        success: function (oArrResult) {
            if (oArrResult != null && oArrResult.length > 0) {
                $.each(oArrResult, function (Index, Val) {
                    Options += "<option value=\"" + Val[Key] + "\">" + Val[Value] + "</option>";
                });
                $("#" + DropDown).html(Options).prop("disabled", false);
            }
            else {
                $("#s2id_" + DropDown + " span:first").text("لا يوجد");
                $("#" + DropDown).html(Options).prop("disabled", true);
            }
            if (Showloading) {
                HideLoader();
            }
        },
        xhr: function () {  // Custom XMLHttpRequest
            var myXhr = $.ajaxSettings.xhr();
            if (myXhr.upload) { // Check if upload property exists
                // Progress code if you want
            }
            return myXhr;
        },
        error: function () {
            if (Showloading) {
                HideLoader();
            }
        }
    });
}
function AjaxCallAndFillCascadeDropDown(Url, HttpVerb, Async, ParentDropDown, ChildDropDown, Key, Value, SelectMessage, NotExist, Parameters, Showloading) {
    var sDefaultSelectOption = "<option value='-99'>" + SelectMessage + "</option>";
    if ($("#" + ParentDropDown).length > 0 && $("#" + ParentDropDown).val() != "" && $("#" + ParentDropDown).val() != "-99") {
        if (Showloading) {
            ShowLoader();
        }
        debugger;
        $("#" + ChildDropDown).html("");
        $.ajax({
            url: Url,
            data: Parameters,
            type: HttpVerb,
            async: Async,
            success: function (oArrResult) {
                if (oArrResult != null && oArrResult.length > 0) {
                    var Options = sDefaultSelectOption;
                    $.each(oArrResult, function (Index, Val) {
                        Options += "<option value=\"" + Val[Key] + "\">" + Val[Value] + "</option>";
                    });
                    $("#" + ChildDropDown).append(Options).prop("disabled", false);
                    $("#s2id_" + ChildDropDown + " span:first").text(SelectMessage);
                }
                else {
                    $("#s2id_" + ChildDropDown + " span:first").text(NotExist);
                    $("#" + ChildDropDown).html("<option value='-99'>" + NotExist + "</option>").prop("disabled", true);
                }
                if (Showloading) {
                    HideLoader();
                }
            }, error: function (ex) {
                if (Showloading) {
                    HideLoader();
                }
            }
        });
    }
    else {
        if (Showloading) {
            HideLoader();
        }
        $("#" + ChildDropDown).html("<option value='-99'>" + NotExist + "</option>").prop("disabled", true);
        $("#s2id_" + ChildDropDown + " span:first").text(NotExist);
    }
}
/*Start FillDropDownRoot: to fill drop down list with onSuccess and onFailure methods  */
function FillDropDownRoot(Url, HttpVerb, Async, DropDownId, Key, Value, SelectMessage, NotExistMessage, Parameters, onSuccess, onFailure) {
    var Options = "<option value='-99'>" + SelectMessage + "</option>";
    var oParameters = [];
    if (null != Parameters && undefined != Parameters) {
        oParameters = Parameters;
    }
    $.ajax({
        url: Url,
        data: oParameters,
        type: HttpVerb,
        async: Async,
        beforeSend: function () { },
        success: function (oArrResult) {
            if (oArrResult != null && oArrResult.length > 0) {
                $.each(oArrResult, function (Index, Val) {
                    Options += "<option value=\"" + Val[Key] + "\">" + Val[Value] + "</option>";
                });
                $("#" + DropDownId).html(Options).prop("disabled", false);
            }
            else {
                $("#s2id_" + DropDownId + " span:first").text(NotExistMessage);
                $("#" + DropDownId).html(Options).prop("disabled", true);
            }
            onSuccess();
        },
        xhr: function () {  // Custom XMLHttpRequest
            var myXhr = $.ajaxSettings.xhr();
            if (myXhr.upload) { // Check if upload property exists
                // Progress code if you want
            }
            return myXhr;
        },
        error: function () {
            onFailure();
        }
    });
}
/*End FillDropDownRoot: to fill drop down list with onSuccess and onFailure methods  */

/*Start FillDropDownRoot: to fill drop down list without initial item  */
function FillDropDownRootWithoutInitItem(Url, HttpVerb, Async, DropDownId, Key, Value, NotExistMessage, Parameters, onSuccess, onFailure) {
    var Options = "";
    var oParameters = [];
    if (null != Parameters && undefined != Parameters) {
        oParameters = Parameters;
    }
    $.ajax({
        url: Url,
        data: oParameters,
        type: HttpVerb,
        async: Async,
        beforeSend: function () { },
        success: function (oArrResult) {
            if (oArrResult != null && oArrResult.length > 0) {
                $.each(oArrResult, function (Index, Val) {
                    Options += "<option value=\"" + Val[Key] + "\">" + Val[Value] + "</option>";
                });
                $("#" + DropDownId).html(Options).prop("disabled", false);
            }
            else {
                $("#s2id_" + DropDownId + " span:first").text(NotExistMessage);
                $("#" + DropDownId).html(Options).prop("disabled", true);
            }
            onSuccess();
        },
        xhr: function () {  // Custom XMLHttpRequest
            var myXhr = $.ajaxSettings.xhr();
            if (myXhr.upload) { // Check if upload property exists
                // Progress code if you want
            }
            return myXhr;
        },
        error: function () {
            onFailure();
        }
    });
}
/*End FillDropDownRoot: to fill drop down list with onSuccess and onFailure methods   */



/*Start FillDropDownCascade: to fill child drop down lists with onSuccess and onFailure methods  */
function FillDropDownCascade(Url, HttpVerb, Async, ParentDropDown, ChildDropDown, Key, Value, SelectMessage, NotExistMessage, Parameters, onSuccess, onFailure) {
    var sDefaultSelectOption = "<option value='-99'>" + SelectMessage + "</option>";
    if ($("#" + ParentDropDown).length > 0 && $("#" + ParentDropDown).val() != "" && $("#" + ParentDropDown).val() != "-99") {

        $("#" + ChildDropDown).html("");
        $.ajax({
            url: Url,
            data: Parameters,
            type: HttpVerb,
            async: Async,
            success: function (oArrResult) {
                if (oArrResult != null && oArrResult.length > 0) {
                    var Options = sDefaultSelectOption;
                    $.each(oArrResult, function (Index, Val) {
                        Options += "<option value=\"" + Val[Key] + "\">" + Val[Value] + "</option>";
                    });
                    $("#" + ChildDropDown).find('option').remove().end();
                    $("#" + ChildDropDown).append(Options);
                    $("#" + ChildDropDown).prop('disabled', false);
                }
                else {
                    $("#" + ChildDropDown).find('option').remove().end().append("<option value='-99'>" + NotExistMessage + "</option>");
                    $("#" + ChildDropDown).prop('disabled', true);
                }
                onSuccess();
            }, error: function (ex) {
                onFailure();
            }
        });
    }
    else {
        $("#" + ChildDropDown).find('option').remove().end().append("<option value='-99'>" + NotExistMessage + "</option>");
        $("#" + ChildDropDown).prop('disabled', true);
    }
}
/*End FillDropDownCascade: to fill child drop down lists with onSuccess and onFailure methods  */


function AjaxCallAndFillCascadeDropDownGrid(Url, HttpVerb, Async, ParentDropDown, ChildDropDown, Key, Value, SelectMessage, Parameters) {
    var sDefaultSelectOption = "<option value='-99'>" + SelectMessage + "</option>";
    if ($("#" + ParentDropDown).length > 0 && $("#" + ParentDropDown).val() != "" && $("#" + ParentDropDown).val() != "-99") {
        $("#" + ChildDropDown).html("");
        $.ajax({
            url: Url,
            data: Parameters,
            type: HttpVerb,
            async: Async,
            success: function (oArrResult) {
                if (oArrResult != null && oArrResult.length > 0) {
                    var Options = sDefaultSelectOption;
                    $.each(oArrResult, function (Index, Val) {
                        Options += "<option value=\"" + Val[Key] + "\">" + Val[Value] + "</option>";
                    });
                    $("#" + ChildDropDown).append(Options).prop("disabled", false);
                }
                else {
                    $("#" + ChildDropDown).append(Options).prop("disabled", true);
                }
            }, error: function (ex) {

            }
        });
    }
    else {
        $("#" + ChildDropDown).html(sDefaultSelectOption).prop("disabled", true);
    }
}
function AjaxWithoutParameters(Url, HttpVerb, Async, Cached, ContentType, ProcessData, Success, Faild) {
    $.ajax({
        url: Url,
        type: HttpVerb,
        async: Async,
        beforeSend: function () { },
        success: Success,
        xhr: function () {  // Custom XMLHttpRequest
            var myXhr = $.ajaxSettings.xhr();
            if (myXhr.upload) { // Check if upload property exists
                // Progress code if you want
            }
            return myXhr;
        },
        error: Faild,
        cache: Cached,
        contentType: ContentType,
        processData: ProcessData
    });
}
function AjaxWithParameters(Url, HttpVerb, Async, Parameters, Success, Faild) {
    $.ajax({
        url: Url,
        data: Parameters,
        type: HttpVerb,
        async: Async,
        success: Success,
        error: Faild
    });
}
function AjaxSubmitForm(Url, HttpVerb, Async, FormName, Success, Faild) {
    var formData = new FormData($("#" + FormName)[0]);
    $.ajax({
        url: Url,
        type: HttpVerb,
        beforeSend: function () { },
        success: Success,
        xhr: function () {  // Custom XMLHttpRequest
            var myXhr = $.ajaxSettings.xhr();
            if (myXhr.upload) { // Check if upload property exists
            }
            return myXhr;
        },
        error: Faild,
        data: formData,
        cache: false,
        contentType: false,
        processData: false
    });
}
///////////////////////////////////////////////////////////////////////// Ajax Calls \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
/////////////////////////////////////////////////////////////////////////Helpers \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
function BuildDataSource(sSelectMessages, JsonDataSourceArray, SelectValue, SelectText) {
    var JsonDataSource = "";
    var JsonDataSourceLength = 0;
    if (JsonDataSourceArray != null && JsonDataSourceArray.length > 0) {
        JsonDataSource = '{"0":"' + sSelectMessages + '",';
        $.each(JsonDataSourceArray, function (Index, Value) {
            JsonDataSource += "\"" + Value[SelectValue] + "\":\"" + Value[SelectText] + "\",";
        });
        JsonDataSourceLength = JsonDataSource.length - 1;
        JsonDataSource = JsonDataSource.substring(0, JsonDataSourceLength);
        JsonDataSource += '}';
        JsonDataSource = $.parseJSON(JsonDataSource);
    }
    return JsonDataSource;
}
function FormatJsonDate(date) {
    if (date == "" || date == undefined || date == null)
        return "";
    var dateString = date.substr(6);
    var currentTime = new Date(parseInt(dateString));
    var month = currentTime.getMonth() + 1;
    var day = currentTime.getDate();
    var year = currentTime.getFullYear();
    var date = day + "/" + month + "/" + year;
    return date;
}
function Value(Ctrl) {
    return $("#" + Ctrl).val();
}
/////////////////////////////////////////////////////////////////////////Helpers \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
function AjaxCallAndFillDropDownReturnSelect(Url, HttpVerb, Async, DropDown, Key, Value, SelectMessage, Width, OnChange, SelectedValue) {
    var Select = "";
    $.ajax({
        url: Url,
        type: HttpVerb,
        async: Async,
        beforeSend: function () { },
        success: function (oArrResult) {
            var Options = "<option value='-99'>" + SelectMessage + "</option>";;
            if (oArrResult != null && oArrResult.length > 0) {
                $.each(oArrResult, function (Index, Val) {
                    if (SelectedValue != -99 && SelectedValue == Val[Key]) {
                        Options += "<option selected='true' value=\"" + Val[Key] + "\">" + Val[Value] + "</option>";
                    }
                    else {
                        Options += "<option value=\"" + Val[Key] + "\">" + Val[Value] + "</option>";
                    }
                });
                Select = "<select onchange='" + OnChange + "' id='" + DropDown + "' style='width:" + Width + "px;' >" + Options + "</select>";
            }
            else {
                Select = "<select  id='" + DropDown + "' style='width:" + Width + "px;' disabled >" + Options + "</select>";
            }
        },
        xhr: function () {  // Custom XMLHttpRequest
            var myXhr = $.ajaxSettings.xhr();
            if (myXhr.upload) { // Check if upload property exists
                // Progress code if you want
            }
            return myXhr;
        },
        error: function () { }
    });
    return Select;
}
function AjaxCallAndFillDropDownReturnSelectWithParameters(Url, HttpVerb, Async, DropDown, Key, Value, SelectMessage, Width, OnChange, SelectedValue, Parameters) {
    var Select = "";
    $.ajax({
        url: Url,
        type: HttpVerb,
        async: Async,
        data: Parameters,
        beforeSend: function () { },
        success: function (oArrResult) {
            var Options = "<option value='-99'>" + SelectMessage + "</option>";;
            if (oArrResult != null && oArrResult.length > 0) {
                $.each(oArrResult, function (Index, Val) {
                    if (SelectedValue != -99 && SelectedValue == Val[Key]) {
                        Options += "<option selected='selected' value=\"" + Val[Key] + "\">" + Val[Value] + "</option>";
                    }
                    else {
                        Options += "<option value=\"" + Val[Key] + "\">" + Val[Value] + "</option>";
                    }
                });

                Select = "<select onchange='" + OnChange + "' id='" + DropDown + "' style='width:" + Width + "px;' >" + Options + "</select>";
            }
            else {
                //Bug fix: to fix bug of more than 2 drop downs cascading
                Select = "<select onchange='" + OnChange + "' id='" + DropDown + "' style='width:" + Width + "px;' >" + Options + "</select>";
                //End Bug fix: to fix bug of more than 2 drop downs cascading
                //Select = "<select  id='" + DropDown + "' style='width:" + Width + "px;' disabled >" + Options + "</select>";
            }
        },
        xhr: function () {  // Custom XMLHttpRequest
            var myXhr = $.ajaxSettings.xhr();
            if (myXhr.upload) { // Check if upload property exists
                // Progress code if you want
            }
            return myXhr;
        },
        error: function () { }
    });
    return Select;
}
function DisableDropDown(SelectMessage, DropDown) {
    var Options = "<option value='-99'>" + SelectMessage + "</option>";
    $("#s2id_" + DropDown + " span:first").text(SelectMessage);
    $("#" + DropDown).html(Options).prop("disabled", true);
}
function QueryValue(name) {
    name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
    var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
        results = regex.exec(location.search);
    return results === null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
}


function RenderLoader(ImagePath) {
    $("#fakeloader").fakeLoader({
        timeToHide: 3000, //Time in milliseconds for fakeLoader disappear
        zIndex: "9999999",//Default zIndex
        spinner: "spinner1",//Options: 'spinner1', 'spinner2', 'spinner3', 'spinner4', 'spinner5', 'spinner6', 'spinner7'
        bgColor: "#ffffff ",  //Hex, RGB or RGBA colors
        imagePath: ImagePath
    });

}
///////////////////////////////////////////////////////////////////////////////////
function FormValidation(FormId, oArrRules, oArrMessages) {
    $('#' + FormId).validate({
        errorElement: 'div',
        errorClass: 'help-block',
        focusInvalid: true,
        ignore: "",
        rules: oArrRules,
        messages: oArrMessages,
        errorPlacement: function (error, element) {
            if (element.is('input[type=checkbox]') || element.is('input[type=radio]')) {
                var controls = element.closest('div[class*="col-"]');
                if (controls.find(':checkbox,:radio').length > 1) controls.append(error);
                else error.insertAfter(element.nextAll('.lbl:eq(0)').eq(0));
            }
            else if (element.is('.select2')) {
                error.insertAfter(element.siblings('[class*="select2-container"]:eq(0)'));
            }
            else if (element.is('.chosen-select')) {
                error.insertAfter(element.siblings('[class*="chosen-container"]:eq(0)'));
            }
            else error.insertAfter(element.parent());
        },
        highlight: function (element) {
            $(element).closest('.form-group').addClass('has-error');
        },
        unhighlight: function (element) {
            $(element).closest('.form-group').removeClass('has-error');
        },
        submitHandler: function (form) {
        },
        invalidHandler: function (form) {
        }
    });
    return $('#' + FormId).valid();
}

///////// Handle  CSRF (XSRF) security [Handle Cross Request Attack]
function AppendAntiForgeryToken(data) {
    //if the object is undefined, create a new one.
    if (!data) {
        data = {};
    }
    //add token
    var tokenInput = $('input[name=__RequestVerificationToken]');
    if (tokenInput.length) {
        data.__RequestVerificationToken = tokenInput.val();
    }
    return data;
};

function FillDropDownJsonSource(oArrJSONSource, DropDown, SelectMessage, Key, Value, Showloading) {
    var Options = "<option value='-99'>" + SelectMessage + "</option>";
    var oParameters = [];
    if (oArrJSONSource != null && oArrJSONSource.length > 0) {
        $.each(oArrJSONSource, function (Index, Val) {
            Options += "<option value=\"" + Val[Key] + "\">" + Val[Value] + "</option>";
        });
        $("#" + DropDown).html(Options).prop("disabled", false);
    }
    else {
        $("#s2id_" + DropDown + " span:first").text("لا يوجد");
        $("#" + DropDown).html(Options).prop("disabled", true);
    }
}


function ShowAjaxLoader() {
    $(document).ajaxStart(function () {
        ShowLoader();
    }).ajaxStop(function () {
        HideLoader();
    });
}

