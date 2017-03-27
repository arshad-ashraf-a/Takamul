/*********************************************************************************************************************
Note                : Show Notification Message [Success-Warning-Information-Error-Modal Massege-Confirmation Message]
**********************************************************************************************************************/
(function ($) {
	var settings = {
		inEffect: { opacity: 'show' },  // in effect
		inEffectDuration: 600, 			// in effect duration in miliseconds
		stayTime: 3000, 			    // time in miliseconds before the item has to disappear
		text: '', 				        // content of the item. Might be a string or a jQuery object. Be aware that any jQuery object which is acting as a message will be deleted when the Notification is fading away.
		sticky: false, 			        // should the Notification item sticky or not?
		type: 'Notice', 			    // Notice, Warning, Error, Success
		position: 'TopRight',          // TopLeft, TopCenter, TopRight, MiddleLeft, MiddleCenter, MiddleRight ... Position of the Notification container holding different Notification. Position can be set only once at the very first call, changing the position after the first call does nothing
		closeText: '',                  // text which will be shown as close button, set to '' when you want to introduce an image via css
		close: null,                    // callback function when the Notificationmessage is closed
		Modal: false,
		Confirmation: false,
		IsAlertDialog: false,
		IsNoButtonAutoPostBack: false,
		IsOKButtonAutoPostBack: false,
		YesButtonText: 'Yes',
		YesRelatedButtonID: '',
		YesButtonEventArgs: '',
		NoButtonText: 'No',
		NoRelatedButtonID: '',
		NoButtonEventArgs: '',
		OkButtonText: 'Ok',
		OkRelatedButtonID: '',
		OkButtonEventArgs: '',
		YesButtonClientFunction: '',
		NoButtonClientFunction: '',
		OkButtonClientFunction: ''
	};

	var methods = {
		init: function (options) {
			if (options) {
				$.extend(settings, options);
			}
		},

		showNotification: function (options) {
			$().Notificationmessage('removeNotification', $('#divNotificationItemInner'), '', 0);
			var localSettings = {};
			$.extend(localSettings, settings, options);
			// declare variables
			var NotificationWrapAll, NotificationItemOuter, NotificationItemInner, NotificationItemClose, NotificationItemImage, ModalWrapper, NotificationItemYes, NotificationItemNo, NotificationItemOK;


			if ($('#' + "newModalDialog").length > 0) {
				$('#' + "newModalDialog").each(function () {
					$(this).remove();
				});
			}

			var divModalDialogMainDiv = $('<div id="' + "newModalDialog" + '" tabindex="-1" aria-hidden="true"></div>').addClass('modal in').appendTo($("body"));//<div class="modal-dialog">

			if ($('.modal-backdrop  in').length <= 0) {
				$('<div id="overlay"/>').addClass('modal-backdrop  in').appendTo(divModalDialogMainDiv);
			}

			var divModalDialog = $('<div></div>').addClass('modal-dialog modal-dialog-confirmation').appendTo(divModalDialogMainDiv);//<div class="modal-dialog">
			var divModalContent = $('<div></div>').addClass('modal-content').appendTo(divModalDialog);//<div class="modal-content">

			var divModalBody = $('<div></div>').addClass('').appendTo(divModalContent);//<div class="modal-body">


			//ModalWrapper = localSettings.Modal ? $("<div id='divNotificationModal'></div>").addClass('Notification-modal').appendTo(divModalContent) : $("<div></div>").appendTo($("form:first"));
			NotificationWrapAll = (!$('.Notification-container').length) ? $('<div></div>').appendTo(divModalBody) : $('.Notification-container');
			NotificationItemOuter = $('<div></div>').addClass('Notification-item-wrapper');

			NotificationItemInner = $('<div id="divNotificationItemInner"></div>').hide().addClass('Notification-item Notification-type-' + localSettings.type).appendTo(NotificationWrapAll).html($('<p>').append(localSettings.text)).animate(localSettings.inEffect, localSettings.inEffectDuration).wrap(NotificationItemOuter);
			NotificationItemClose = $('<div></div>').addClass('Notification-item-close').prependTo(NotificationItemInner).html(localSettings.closeText).click(function () { $().Notificationmessage('removeNotification', NotificationItemInner, localSettings, 100); CloseMaskDialog(); });

			if (localSettings.Confirmation) {
				//Prepare Yes Button Function:
				var sYesButtonFunction = function () {
					//Close Current Confirmation Dialog:
					$().Notificationmessage('removeNotification', NotificationItemInner, localSettings, 0);
					//Call Yes Button Client Function:
					CloseMaskDialog();
					var isReturnFunction = false;
					var bReturnedValue = false;
					if (typeof localSettings.YesButtonClientFunction === 'function' && localSettings.YesButtonClientFunction !== '') {
						bReturnedValue = localSettings.YesButtonClientFunction();
						if (typeof bReturnedValue !== 'undefined') {
							isReturnFunction = true;
						}
					}

					if (isReturnFunction) {
						return bReturnedValue;
					}
					//Do Postback to buuton target:
					javascript: __doPostBack(localSettings.YesRelatedButtonID, localSettings.YesButtonEventArgs);
				}
				//Prepare No Button Function:
				var sNoButtonFunction = function () {
					//Close Current Confirmation Dialog:
					$().Notificationmessage('removeNotification', NotificationItemInner, localSettings, 0);
					CloseMaskDialog();
					//Call No Button Client Function:
					var isReturnFunction = false;
					var bReturnedValue = false;
					if (typeof localSettings.NoButtonClientFunction === 'function' && localSettings.NoButtonClientFunction !== '') {
						bReturnedValue = localSettings.NoButtonClientFunction();
						if (typeof bReturnedValue !== 'undefined') {
							isReturnFunction = true;
						}
					}

					if (isReturnFunction) {
						return bReturnedValue;
					}
					//Do Postback to buuton target:
					if (localSettings.IsNoButtonAutoPostBack) {
						javascript: __doPostBack(localSettings.NoRelatedButtonID, localSettings.NoButtonEventArgs);
					}
				}
				//Set Yes Button Value:
				NotificationButtons = $('<div></div>').addClass('clearfix').prependTo(NotificationItemInner);
				NotificationItemYes = $('<div></div>').addClass('Notification-item-btnYesContainer').appendTo(NotificationButtons).html("<input id='btnYes' type='button' class='btn btn-white btn-round' value='" + localSettings.YesButtonText + "' />").click(sYesButtonFunction);
				//Set No Button Value:
				NotificationItemNo = $('<div></div>').addClass('Notification-item-btnNoContainer').appendTo(NotificationButtons).html("<input id='btnNo' type='button' class='btn btn-white btn-round' value='" + localSettings.NoButtonText + "' />").click(sNoButtonFunction);
				$("#btnNo").focus();

				var MaskDialogID = 'divMaskDialog' + "newModalDialog"; //EX: divMaskDialogucPoll_divPoll
				//Fill the dialog description from the specified control content
				$('#' + MaskDialogID + 'divDialogDesc').html($('#' + "newModalDialog"));
				$('#' + "newModalDialog").css('display', 'block');
				$('#' + MaskDialogID).show();
				$('body').addClass('modal-open');

			}
			if (localSettings.IsAlertDialog) {
				if (localSettings.IsOKButtonAutoPostBack) {
					NotificationItemOK = $('<div></div>').addClass('Notification-item-btnOkContainer').prependTo(NotificationItemInner).html("<input id='btnOk' type='button' class='btn btn-white btn-round' value='" + localSettings.OkButtonText + "' />").click(function () { $().Notificationmessage('removeNotification', NotificationItemInner, localSettings, 100); javascript: __doPostBack(localSettings.OkRelatedButtonID, localSettings.OkButtonEventArgs); });
				}
				else {
					NotificationItemOK = $('<div></div>').addClass('Notification-item-btnOkContainer').prependTo(NotificationItemInner).html("<input id='btnOk' type='button' class='btn btn-white btn-round' value='" + localSettings.OkButtonText + "' />").click(CloseMaskDialog);
				}
				$("#btnOk").focus();
				$('#' + MaskDialogID + 'divDialogDesc').html($('#' + "newModalDialog"));
				$('#' + "newModalDialog").css('display', 'block');
				$('#' + MaskDialogID).show();
				$('body').addClass('modal-open');

			}
			NotificationItemImage = $('<div></div>').addClass('Notification-item-image').addClass('Notification-item-image-' + localSettings.type).prependTo(NotificationItemInner);

			if (navigator.userAgent.match(/MSIE 6/i)) {
				NotificationWrapAll.css({ top: document.documentElement.scrollTop });
			}

			if (!localSettings.sticky) {
				setTimeout(function () {
					$().Notificationmessage('removeNotification', NotificationItemInner, localSettings, 600);
				},
				localSettings.stayTime);
			}


			var leftPosition = 0;
			var MainContainer = $("*[notificationMainContainer='true']");
			if (MainContainer.length === 0) {
				MainContainer = $(document);
			}
			else {
				var position = MainContainer.position();
				leftPosition = position.left
			}

			var MainElementWidth = MainContainer.width();
			var NotificationCenter = (MainElementWidth / 2) - (Math.round($(".Notification-item-wrapper").width() / 2)) - 22 + leftPosition;
			$(".Notification-position-MiddleCenter").css("left", NotificationCenter + "px");
			$(".Notification-position-MiddleCenter").css("right", NotificationCenter + "px");
			return false;
		},

		showNoticeNotification: function (message) {
			var options = { text: message, type: 'Notice' };
			return $().Notificationmessage('showNotification', options);
		},

		showSuccessNotification: function (message) {
			var options = { text: message, type: 'Success' };
			return $().Notificationmessage('showNotification', options);
		},

		showErrorNotification: function (message) {
			var options = { text: message, type: 'Error' };
			return $().Notificationmessage('showNotification', options);
		},

		showWarningNotification: function (message) {
			var options = { text: message, type: 'Warning' };
			return $().Notificationmessage('showNotification', options);
		},

		removeNotification: function (obj, options, inEffectDuration) {
			inEffectDuration = typeof inEffectDuration !== 'undefined' ? inEffectDuration : 0;
			if (inEffectDuration !== '0' && inEffectDuration !== '') {
				obj.find('.Notification-item-close').animate({ opacity: '0' }, inEffectDuration); // IE8 Problem.
				obj.find('.Notification-item-btnYesContainer').animate({ opacity: '0' }, inEffectDuration); // IE8 Problem.
				obj.find('.Notification-item-btnNoContainer').animate({ opacity: '0' }, inEffectDuration); // IE8 Problem.
				obj.find('.Notification-item-btnNoContainer').animate({ opacity: '0' }, inEffectDuration); // IE8 Problem.
				obj.find('.Notification-item-image').animate({ opacity: '0' }, inEffectDuration); // IE8 Problem.
			}
			$("#divNotificationModal").remove(); 
			obj.animate({ opacity: '0' }, inEffectDuration, function () {
				obj.parent().animate({ height: '0px' }, inEffectDuration, function () {
					obj.parent().remove();
				});
			});
			// callback
			if (options && options.close !== null) {
				options.close();
			}
		}
	};

	$.fn.Notificationmessage = function (method) {

		// Method calling logic
		if (methods[method]) {
			return methods[method].apply(this, Array.prototype.slice.call(arguments, 1));
		} else if (typeof method === 'object' || !method) {
			return methods.init.apply(this, arguments);
		} else {
			$.error('Method ' + method + ' does not exist on jQuery.Notificationmessage');
		}
	};

})(jQuery);

function ShowConfirmation(sMessageContent, sYesButtonText, sNoButtonText, sYesButtonEventTarget, sYesButtonEventArgs, bIsNoButtonAutoPostBack, sNoButtonEventTraget, sNoButtonEventArgs, sValidationGroup, sYesButtonClientFunction, sNoButtonClientFunction) {
	//--->Begin Set Parameters Default Values:

	var IsNoButtonAutoPostBack = typeof bIsNoButtonAutoPostBack !== 'undefined' ? bIsNoButtonAutoPostBack : false;
	var NoButtonEventTraget = typeof sNoButtonEventTraget !== 'undefined' ? sNoButtonEventTraget : '';
	var YesButtonEventArgs = typeof sYesButtonEventArgs !== 'undefined' ? sYesButtonEventArgs : '';
	var NoButtonEventArgs = typeof sNoButtonEventArgs !== 'undefined' ? sNoButtonEventArgs : '';
	var ValidationGroup = typeof sValidationGroup !== 'undefined' ? sValidationGroup : '';
	var YesButtonJSFunction = typeof sYesButtonClientFunction === 'function' ? sYesButtonClientFunction : '';
	var NoButtonJSFunction = typeof sNoButtonClientFunction === 'function' ? sNoButtonClientFunction : '';
	//<---End  Set Parameters Default Values.
	var PageIsValid = true;
	if (ValidationGroup !== '' && (typeof (Page_ClientValidate) === 'function') && (typeof Page_ClientValidate(ValidationGroup) !== "undefined")) {
		PageIsValid = Page_ClientValidate(ValidationGroup);
	}
	Page_BlockSubmit = false;

	if (PageIsValid) {
		$().Notificationmessage('showNotification', {
			sticky: true,
			type: 'Warning',
			position: 'MiddleCenter',
			text: sMessageContent,
			Modal: true,
			Confirmation: true,
			IsNoButtonAutoPostBack: IsNoButtonAutoPostBack,
			YesButtonText: sYesButtonText,
			YesRelatedButtonID: sYesButtonEventTarget,
			YesButtonEventArgs: YesButtonEventArgs,
			NoButtonText: sNoButtonText,
			NoRelatedButtonID: NoButtonEventTraget,
			NoButtonEventArgs: NoButtonEventArgs,
			YesButtonClientFunction: YesButtonJSFunction,
			NoButtonClientFunction: NoButtonJSFunction
		});
	}
	return false;
}


function ShowAlertDialog(sMessageContent, sOkButtonText, bIsOkButtonAutoPostBack, sOkRelatedButtonID, sOkButtonEventArgs) {
	debugger;
	var IsOkButtonAutoPostBack = typeof bIsOkButtonAutoPostBack !== 'undefined' ? bIsOkButtonAutoPostBack : false; //Default value for parameter.
	var OkRelatedButtonID = typeof sOkRelatedButtonID !== 'undefined' ? sOkRelatedButtonID : ''; //Default value for parameter.
	var OkButtonEventArgs = typeof sOkButtonEventArgs !== 'undefined' ? sOkButtonEventArgs : ''; //Default value for parameter.

	return $().Notificationmessage('showNotification', {
		text: sMessageContent,
		sticky: true,
		type: 'Notice',
		position: 'MiddleCenter',
		Modal: true,
		IsAlertDialog: true,
		IsOKButtonAutoPostBack: bIsOkButtonAutoPostBack,
		OkButtonText: sOkButtonText,
		OkRelatedButtonID: OkRelatedButtonID,
		OkButtonEventArgs: OkButtonEventArgs
	});
}

//This function to show StatusBar status message:

function ShowStatusBarNotification(sMessage, MessageClass) {
	//If Another message is called before previous removed:
	$(".StatusBarWrapper").remove();
	if (typeof StatusBarNotificationTimer !== 'undefined') {
		clearTimeout(StatusBarNotificationTimer);
	}

	var divStatusBarWrapper = $("<div class='StatusBarWrapper' style='display:block;'></div>").addClass(MessageClass).css("display", "block").appendTo($("body:first"));
	var divStatusBarContent = $("<div class='StatusBarContent'  id='divStatusBarMessage'></div>").text(sMessage).appendTo(divStatusBarWrapper);
	var divStatusBarClose = $("<div class='StatusBarClose' title='Close'></div>").click(function () { RemoveStatusBarNotification(); }).appendTo(divStatusBarWrapper);
	$(".StatusBarWrapper").mouseenter(function () {
		window.clearInterval(StatusBarNotificationTimer);
	});
	$(".StatusBarWrapper").mouseleave(function () {
		StatusBarNotificationTimer = setTimeout(function () { RemoveStatusBarNotification() }, 3000);
	});

	StatusBarNotificationTimer = setTimeout(function () { RemoveStatusBarNotification() }, 3000);
}

//This function to remove StatusBar status message:

function RemoveStatusBarNotification() {
	$(".StatusBarWrapper").slideToggle(1000, function () { $(this).remove(); });
}

//This function is used to show alert dialog and call passed js function for yes and no buttons
//without cause postback; if you want to call js function on yes button click and then postback to specafic 
//control event you can use (ShowConfirmation) function.
//this function only for optimize parameter list that passed to (ShowConfirmation) function.

function ShowConfirmationWithClientResponse(sMessageContent, sYesButtonText, sNoButtonText, sYesButtonClientFunction, sNoButtonClientFunction) {
	return ShowConfirmation(sMessageContent, sYesButtonText, sNoButtonText, '', '', '', '', '', '', sYesButtonClientFunction, sNoButtonClientFunction);
}

//Mask Dialog Functions
///<summary>
///Creates the mask dialog
///</summary>
///<Parameter name = "MaskDialogID">Mask Dialog ID</Parameter>
///<Parameter name = "MaskDialogTitle">Mask Dialog title text</Parameter>
///<Parameter name = "MaskDialogCloseButtonText">Mask Dialog Close Button Text</Parameter>
///<Parameter name = "MaskDialogWidth">Mask Dialog Width</Parameter>
//[By ahilo 24.3.2013]
function CreateMaskDialog(MaskDialogID, MaskDialogTitle, MaskDialogCloseButtonText, MaskDialogWidth, IsPkiDialog) {

	//
	CloseMaskDialog(); //Close the dialog if its opened :: Handles the case when open the dialog from other dialog
	//Create new dialog if there is no one in the page with the specified ID

	if ($('#' + MaskDialogID).length <= 0) {
		//Create the overlay div only once in the page
		var divModalDialogMainDiv = $('<div id="' + MaskDialogID + '" tabindex="-1" aria-hidden="true"></div>').addClass('modal in').appendTo($("form"));//<div class="modal-dialog">
		if (IsPkiDialog) {
			if ($('.modal-backdrop-pki  in').length <= 0) {
				$('<div id="overlay"/>').addClass('modal-backdrop-pki  in').appendTo(divModalDialogMainDiv);
			}
		}
		else {
			if ($('.modal-backdrop  in').length <= 0) {
				$('<div id="overlay"/>').addClass('modal-backdrop  in').appendTo(divModalDialogMainDiv);
			}
		}

		var divModalDialog = $('<div></div>').addClass('modal-dialog').appendTo(divModalDialogMainDiv);//<div class="modal-dialog">

		//if (!IsPkiDialog) {
		if (!isNaN(parseInt(MaskDialogWidth)) && parseInt(MaskDialogWidth) > 100) {
			divModalDialog.css('width', MaskDialogWidth);
		}
		else {
			divModalDialog.css('width', 'auto');
		}
		//}

		var divModalContent = $('<div></div>').addClass('modal-content').appendTo(divModalDialog);//<div class="modal-content">

		var divModalHeader = $('<div></div>').addClass('widget-header').appendTo(divModalContent);//<div class="widget-header">
		var divModalBody = $('<div></div>').addClass('modal-body').appendTo(divModalContent);//<div class="modal-body">
		//var divModalFooter = $('<div></div>').addClass('modal-footer').appendTo(divModalContent);//<div class="modal-footer"> For now footer is empty --- TODO:: Handle the footer content

		if (!IsPkiDialog) {
			var buttonClose = $('<div data-dismiss="modal" onClick="CloseMaskDialog();"></div>').addClass('close-popup').appendTo(divModalHeader);//<div class="modal-footer">
		}
		var h4HeaderContent = $('<h4 id="h4BlueBiggerTitle"></h4>').addClass('white smaller margin-top-pop-head').appendTo(divModalHeader);//<div class="modal-footer">


		var divDialogBody = $('<div id="' + MaskDialogID + 'divDialogDesc"/>').appendTo(divModalBody);



		var MaskDialog = $('#' + MaskDialogID);
		if (typeof MaskDialogTitle !== 'undefined' && MaskDialogTitle !== '') {
			h4HeaderContent.html(MaskDialogTitle);
		}
		//if (typeof MaskDialogCloseButtonText !== 'undefined' && MaskDialogCloseButtonText != '') {

		//    //buttonClose.html(MaskDialogCloseButtonText);
		//    buttonClose.html(MaskDialogCloseButtonText);
		//}
		//else {
		//    buttonClose.html('X');
		//}
	}
	else {
		$('.modal').show();
		if (IsPkiDialog) {
			$('.modal-backdrop-pki').show();
		}
		else {
			$('.modal-backdrop').show();
		}
		$('body').addClass('modal-open');
	}
}

///Open Mask Dialog and Render Text
///<summary>
///Opens the Mask Dialog
///</summary>
///<Parameter name = "MaskDialogTitle">Mask Dialog Title Text</Parameter>
///<Parameter name = "MaskDialogDesc">Mask Dialog Description Text</Parameter>
///<Parameter name = "MaskDialogCloseButtonText">Mask Dialog Close Button Text</Parameter>
///<Parameter name = "MaskDialogWidth">Mask Dialog Width</Parameter>
//[By ahilo 24.3.2013]
function OpenMaskDialogText(MaskDialogTitle, MaskDialogDesc, MaskDialogCloseButtonText, MaskDialogWidth) {
	var MaskDialogID = 'divMaskDialog';
	CreateMaskDialog(MaskDialogID, MaskDialogTitle, MaskDialogCloseButtonText, MaskDialogWidth, false);
	//Fill the dialog title and description if it exists
	if (typeof MaskDialogDesc !== 'undefined' && MaskDialogDesc !== '') {
		$('.DialogDesc').html(MaskDialogDesc);
	}

	$('#' + MaskDialogID).fadeIn();
	//$('#' + MaskDialogID).resizable({ handles: resizeDirection }).draggable();

	return false;
}

///Open Mask Dialog and Render Control
///<summary>
///Opens the Mask Dialog
///</summary>
///<Parameter name = "MaskDialogTitle">Mask Dialog Title Text</Parameter>
///<Parameter name = "MaskDialogDescControlClientID">Mask Dialog Description Control ID to Be Rendered</Parameter>
///<Parameter name = "MaskDialogCloseButtonText">Mask Dialog Close Button Text</Parameter>
///<Parameter name = "MaskDialogWidth">Mask Dialog Width</Parameter>
//[By ahilo 24.3.2013]
function OpenMaskDialogControl(MaskDialogTitle, MaskDialogDescControlClientID, MaskDialogCloseButtonText, MaskDialogWidth) {
	var MaskDialogID = 'divMaskDialog' + MaskDialogDescControlClientID; //EX: divMaskDialogucPoll_divPoll
	CreateMaskDialog(MaskDialogID, MaskDialogTitle, MaskDialogCloseButtonText, MaskDialogWidth, false);
	//Fill the dialog description from the specified control content
	$('#' + MaskDialogID + 'divDialogDesc').html($('#' + MaskDialogDescControlClientID));
	$('#' + MaskDialogDescControlClientID).css('display', 'block');
	$('#' + MaskDialogID).fadeIn();
	$('body').addClass('modal-open');
	//$('#' + MaskDialogID).resizable({ handles: resizeDirection }).draggable();
	//$('#' + MaskDialogID).css("min-height", ($('#' + MaskDialogDescControlClientID).outerHeight()) + "px");
	//$('#' + MaskDialogID).css("min-height", $('#' + MaskDialogID).outerHeight());
	return false;
}




///Open Mask Dialog and Render Control
///<summary>
///Opens the Mask Dialog
///</summary>
///<Parameter name = "MaskDialogTitle">Mask Dialog Title Text</Parameter>
///<Parameter name = "MaskDialogDescControlClientID">Mask Dialog Description Control ID to Be Rendered</Parameter>
///<Parameter name = "MaskDialogCloseButtonText">Mask Dialog Close Button Text</Parameter>
///<Parameter name = "MaskDialogWidth">Mask Dialog Width</Parameter>

function OpenMaskDialogControlStuck(MaskDialogTitle, MaskDialogDescControlClientID, MaskDialogCloseButtonText, MaskDialogWidth) {
	var MaskDialogID = 'divMaskDialog' + MaskDialogDescControlClientID; //EX: divMaskDialogucPoll_divPoll
	CreateMaskDialog(MaskDialogID, MaskDialogTitle, MaskDialogCloseButtonText, MaskDialogWidth, true);
	//Fill the dialog description from the specified control content
	$('#' + MaskDialogID + 'divDialogDesc').html($('#' + MaskDialogDescControlClientID));
	$('#' + MaskDialogDescControlClientID).css('display', 'block');
	$('#' + MaskDialogID).fadeIn();
	$('body').addClass('modal-open');
	$('.modal-backdrop-pki').show();

	//$('#' + MaskDialogID).resizable({ handles: resizeDirection }).draggable();
	//$('#' + MaskDialogID).css("min-height", ($('#' + MaskDialogDescControlClientID).outerHeight()) + "px");
	//$('#' + MaskDialogID).css("min-height", $('#' + MaskDialogID).outerHeight());
	return false;
}



///<summary>
///Closes the Mask Dialog
///</summary>
//[By ahilo 24.3.2013]
function CloseMaskDialog() {
	$('.modal').hide();
	$('.modal-backdrop').hide();
	$('body').removeClass('modal-open');
	return false;
}

///<summary>
///Closes the Mask Dialog (PKI)
///</summary>

function CloseMaskDialogPKI() {
	$('.modal').hide();
	$('.modal-backdrop-pki').hide();
	$('body').removeClass('modal-open');
	return false;
}

//[Close confirmation dialog - Mask Dialog when user click outside of dialog]
$(document).on('click', ".modal-backdrop", function () {
	//
	$('.modal').hide();
	$('.modal-backdrop').hide();
	$('body').removeClass('modal-open');
});


//[Close confirmation dialog - Mask Dialog when user hit esc key]
$(document).keyup(function (e) {
	//
	//Esc Key Clicked:
	if (e.keyCode === 27) {
		$().Notificationmessage('removeNotification', $('#divNotificationItemInner'), '', 0);
		CloseMaskDialog();
	}
});

//[Close confirmation dialog - Mask Dialog when user hit esc key]
function bIsNotificationShowen() {
	return $('#divNotificationItemInner').length !== 0;
}