using Infrastructure.Core;
using Infrastructure.Utilities;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Xml.Linq;
using Takamul.Models;
using Takamul.Models.ViewModel;
using Takamul.Portal.Resources.Common;
using Takamul.Portal.Resources.Portal.ApplicationInfo;
using Takamul.Services;

namespace LDC.eServices.Portal.Controllers
{
    public class ApplicationInfoController : DomainController
    {
        #region ::   State   ::
        #region Private Members
        private IApplicationInfoService oIApplicationInfoService;
        #endregion
        #endregion

        #region :: Constructor ::
        public ApplicationInfoController(IApplicationInfoService IApplicationInfoServiceInitializer)
        {
            oIApplicationInfoService = IApplicationInfoServiceInitializer;
        }
        #endregion

        #region :: Behaviors ::

        #region View :: ApplicationInfoList
        /// <summary>
        /// List of member info
        /// </summary>
        /// <returns></returns>
        public ActionResult ApplicationInfoList()
        {
            this.CurrentPage = ApplicationInfoResx.ApplicationInfo;
            this.TitleHead = ApplicationInfoResx.ApplicationInfo;

            return View();
        }
        #endregion

        #region View :: PartialAddApplicationInfo
        /// <summary>
        /// Add application info
        /// </summary>
        /// <returns></returns>
        public PartialViewResult PartialAddApplicationInfo()
        {
            ApplicationInfoViewModel oApplicationInfoViewModel = new ApplicationInfoViewModel();
            oApplicationInfoViewModel.APPLICATION_ID = CurrentApplicationID;
            return PartialView("_AddApplicationInfo", oApplicationInfoViewModel);
        }
        #endregion

        #region View :: PartialEditApplicationInfo
        /// <summary>
        ///  Edit application info
        /// </summary>
        /// <param name="oMemberInfoViewModel"></param>
        /// <returns></returns>
        public PartialViewResult PartialEditApplicationInfo(ApplicationInfoViewModel oApplicationInfoViewModel)
        {
            oApplicationInfoViewModel.APPLICATION_ID = CurrentApplicationID;
            return PartialView("_EditApplicationInfo", oApplicationInfoViewModel);
        }
        #endregion

        #endregion

        #region :: Methods ::

        #region Method :: JsonResult :: GetAllApplicationInfo
        /// <summary>
        /// Get all application info
        /// </summary>
        /// <param name="nPage"></param>
        /// <param name="nRows"></param>
        /// <param name="sColumnName"></param>
        /// <param name="sColumnOrder"></param>
        /// <returns></returns>
        [HttpPost]
        public JsonResult JGetAllApplicationInfo(int nPage, int nRows, string sColumnName, string sColumnOrder)
        {
            var list = oIApplicationInfoService.IlGetAllApplicationInfo(this.CurrentApplicationID, nPage, nRows, sColumnName, sColumnOrder);
            return Json(list, JsonRequestBehavior.AllowGet);
        }
        #endregion

        #region Method :: JsonResult :: Save application info
        /// <summary>
        /// Save application info
        /// </summary>
        /// <param name="oApplicationInfoViewModel"></param>
        /// <returns></returns>
        [HttpPost]
        [ValidateAntiForgeryToken()]
        public JsonResult JSaveApplicationInfo(ApplicationInfoViewModel oApplicationInfoViewModel)
        {
            Response oResponseResult = null;

            oApplicationInfoViewModel.CREATED_BY = Convert.ToInt32(CurrentUser.nUserID);

            oResponseResult = this.oIApplicationInfoService.oInsertApplicationInfo(oApplicationInfoViewModel);
            this.OperationResult = oResponseResult.OperationResult;

            switch (this.OperationResult)
            {
                case enumOperationResult.Success:
                    this.OperationResultMessages = CommonResx.MessageAddSuccess;
                    break;
                case enumOperationResult.RelatedRecordFaild:
                    this.OperationResultMessages = ApplicationInfoResx.AlreadyAddedMaximumList;
                    break;
                case enumOperationResult.Faild:
                    this.OperationResultMessages = CommonResx.MessageAddFailed;
                    break;
            }
            return Json(
                new
                {
                    nResult = this.OperationResult,
                    sResultMessages = this.OperationResultMessages
                },
                JsonRequestBehavior.AllowGet);
        }
        #endregion

        #region Method :: JsonResult :: Edit application info
        /// <summary>
        /// Edit application info
        /// </summary>
        /// <param name="oApplicationInfoViewModel"></param>
        /// <returns></returns>
        [HttpPost]
        [ValidateAntiForgeryToken()]
        public JsonResult JEditApplicationInfo(ApplicationInfoViewModel oApplicationInfoViewModel)
        {
            Response oResponseResult = null;

            oApplicationInfoViewModel.MODIFIED_BY = Convert.ToInt32(CurrentUser.nUserID);

            oResponseResult = this.oIApplicationInfoService.oUpdateApplicationInfo(oApplicationInfoViewModel);
            this.OperationResult = oResponseResult.OperationResult;

            switch (this.OperationResult)
            {
                case enumOperationResult.Success:
                    this.OperationResultMessages = CommonResx.MessageEditSuccess;
                    break;
                case enumOperationResult.Faild:
                    this.OperationResultMessages = CommonResx.MessageEditFailed;
                    break;
            }
            return Json(
                new
                {
                    nResult = this.OperationResult,
                    sResultMessages = this.OperationResultMessages
                },
                JsonRequestBehavior.AllowGet);
        }
        #endregion

        #region Method :: JsonResult :: Delete Application Info
        /// <summary>
        ///  Delete application info
        /// </summary>
        /// <param name="ID"></param>
        /// <returns></returns>
        [HttpPost]
        public JsonResult JDeleteApplicationInfo(string ID)
        {
            Response oResponseResult = null;

            oResponseResult = this.oIApplicationInfoService.oDeleteApplicationInfo(Convert.ToInt32(ID));
            this.OperationResult = oResponseResult.OperationResult;

            switch (this.OperationResult)
            {
                case enumOperationResult.Success:
                    this.OperationResultMessages = CommonResx.MessageDeleteSuccess;
                    break;
                case enumOperationResult.Faild:
                    this.OperationResultMessages = CommonResx.MessageDeleteFailed;
                    break;
            }
            return Json(
                new
                {
                    nResult = this.OperationResult,
                    sResultMessages = this.OperationResultMessages
                },
                JsonRequestBehavior.AllowGet);
        }
        #endregion

        #endregion
    }
}