using Infrastructure.Core;
using Infrastructure.Utilities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Takamul.Models;
using Takamul.Models.ViewModel;
using Takamul.Portal.Resources.Common;
using Takamul.Portal.Resources.Portal.Member;
using Takamul.Services;

namespace Takamul.Portal.Controllers
{
    public class NotificationController : BaseController
    {
        #region ::  State ::
        #region Private Members
        private ICommonServices oICommonServices;
        #endregion
        #endregion

        #region Constructor
        /// <summary>
        /// UsersController Constructor 
        /// </summary>
        /// <param name="oIUserServicesInitializer"></param>
        public NotificationController(ICommonServices oICommonServicesInitializer)
        {
            this.oICommonServices = oICommonServicesInitializer;
        }
        #endregion 

        #region :: Behaviour ::

        #region View :: PushNotificationLogsList
        public ActionResult PushNotificationLogsList()
        {
            this.PageTitle = CommonResx.NotificationLogs;
            this.TitleHead = CommonResx.NotificationLogs;

            return View();
        }
        #endregion

        #endregion

        #region ::  Methods ::

        #region Method :: JsonResult :: JGetPushNotificationLogs
        /// <summary>
        /// Get all push notification logs
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        public JsonResult JGetPushNotificationLogs(int nApplicationID, int nPage, int nRows, string sColumnName, string sColumnOrder)
        {
            var lstUsers = this.oICommonServices.oGetPushNotificationLogs(nApplicationID, nPage, nRows);
            return Json(lstUsers, JsonRequestBehavior.AllowGet);
        }
        #endregion

        #endregion

    }
}