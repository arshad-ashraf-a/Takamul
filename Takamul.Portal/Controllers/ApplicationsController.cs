using Infrastructure.Core;
using Infrastructure.Utilities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Takamul.Portal.Resources.Common;
using Takamul.Services;

namespace LDC.eServices.Portal.Controllers
{
    public class ApplicationsController : BaseController
    {
        #region ::  State ::
        #region Private Members
        private IApplicationService oIApplicationService;
        #endregion
        #endregion

        #region Constructor
        /// <summary>
        /// ApplicationsController Constructor 
        /// </summary>
        /// <param name="oIApplicationServiceInitializer"></param>
        public ApplicationsController(IApplicationService oIApplicationServiceInitializer)
        {
            this.oIApplicationService = oIApplicationServiceInitializer;
        }
        #endregion

        #region :: Behaviour ::

        #region View :: ApplicationsList
        public ActionResult ApplicationsList()
        {
            this.PageTitle = "Applications List";
            this.TitleHead = "Applications List";

            return View();
        }
        #endregion

        #region View :: ApplicationsDetails
        public ActionResult ApplicationsDetails()
        {
            this.TitleHead = "Application Details";
            return View();
        }
        #endregion

        #endregion

        #region ::  Methods ::

        #region JsonResult :: Bind Grid All Applications
        /// <summary>
        /// Bind Training License Data
        /// </summary>
        /// <param name="nPage"></param>
        /// <param name="nRows"></param>
        /// <param name="sColumnName"></param>
        /// <param name="sColumnOrder"></param>
        /// <returns></returns>
        public JsonResult JBindAllApplications(int nSearchByApplicationID,string sSearchByApplicationName,int nPage, int nRows, string sColumnName, string sColumnOrder)
        {
            var lstApplications = this.oIApplicationService.IlGetAllApplications(nSearchByApplicationID, sSearchByApplicationName,nPage, nRows, sColumnName, sColumnOrder);
            return Json(lstApplications, JsonRequestBehavior.AllowGet);
        }
        #endregion

        #region JsonResult :: JSetCurrentApplicationID
        /// <summary>
        /// Set Current Application ID In Current User Object
        /// </summary>
        /// <param name="nApplicationID"></param>
        /// <returns></returns>
        [HttpPost]
        public JsonResult JSetCurrentApplicationID(int nApplicationID)
        {
            this.OperationResult = enumOperationResult.Faild;
            this.OperationResultMessages = CommonResx.GeneralError;
            if (CurrentUser != null)
            {
                this.CurrentApplicationID = nApplicationID;
                this.OperationResult = enumOperationResult.Success;
                this.OperationResultMessages = CommonResx.MessageAddSuccess;
            }
            return Json(new
            {
                nResult = this.OperationResult,
                sResultMessages = this.OperationResultMessages
            }, JsonRequestBehavior.AllowGet);
        }
        #endregion

        #endregion
    }
}