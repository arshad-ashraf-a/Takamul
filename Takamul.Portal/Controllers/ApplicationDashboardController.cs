
using Infrastructure.Core;
using Infrastructure.Utilities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Takamul.Models.ViewModel;
using Takamul.Portal.Helpers;
using Takamul.Portal.Resources.Common;
using Takamul.Services;

namespace LDC.eServices.Portal.Controllers
{
    public class ApplicationDashboardController : DomainController
    {
        #region ::  State ::
        #region Private Members
        private IApplicationService oIApplicationService;
        private ICommonServices oICommonServices;
        #endregion
        #endregion

        #region Constructor
        /// <summary>
        /// ApplicationDashboardController Constructor 
        /// </summary>
        /// <param name="oIApplicationServiceInitializer"></param>
        public ApplicationDashboardController(IApplicationService oIApplicationServiceInitializer, ICommonServices oICommonServicesInitializer)
        {
            this.oIApplicationService = oIApplicationServiceInitializer;
            this.oICommonServices = oICommonServicesInitializer;
        }
        #endregion

        #region :: Behaviour ::

        #region View :: AppDashboard
        public ActionResult AppDashboard()
        {
            //PushNotification oPushNotification = new PushNotification();
            //oPushNotification.NotificationType = enmNotificationType.News;
            //oPushNotification.sHeadings = "اختبار";
            //oPushNotification.sContent = "اختبار ديسك";
            //oPushNotification.enmLanguage = Data.Core.Languages.Arabic;
            //oPushNotification.sRecordID = "3144";
            //oPushNotification.SendPushNotification();
            //NotificationLogViewModel oNotificationLogViewModel = new NotificationLogViewModel();
            //oNotificationLogViewModel.APPLICATION_ID = this.CurrentApplicationID;
            //oNotificationLogViewModel.NOTIFICATION_TYPE = "news";
            //oNotificationLogViewModel.REQUEST_JSON = oPushNotification.sRequestJSON;
            //oNotificationLogViewModel.RESPONSE_MESSAGE = oPushNotification.sResponseResult;
            //oNotificationLogViewModel.IS_SENT_NOTIFICATION = oPushNotification.bIsSentNotification;
            //oICommonServices.oInsertNotificationLog(oNotificationLogViewModel);

            this.TitleHead = CommonResx.AppDashBoard;

            ApplicationViewModel oApplicationViewModel = this.oIApplicationService.oGetApplicationStatistics(this.CurrentApplicationID);
            this.CurrentApplicationName = oApplicationViewModel.APPLICATION_NAME;
            return View(oApplicationViewModel);
        }
        #endregion

        #endregion
    }
}